import { describe, it, expect, afterEach } from 'vitest';
import type { Application } from '@hotwired/stimulus';

import DynamicListRecordController from './dynamic-list-record-controller.js';
import { startStimulusWith } from '../../test/stimulus.js';

describe('DynamicListRecordController', () => {
  let application: Application | null = null;

  afterEach(() => {
    application?.stop();
    application = null;
  });

  async function renderRecords(recordsHtml: string) {
    document.body.innerHTML = recordsHtml;
    application = await startStimulusWith({
      'dynamic-list-record': DynamicListRecordController,
    });
  }

  it('removes rows that have no destroy field from the DOM', async () => {
    await renderRecords(`
      <div class="row" data-controller="dynamic-list-record">
        <button type="button" data-dynamic-list-record-target="deleteButton"
                data-action="click->dynamic-list-record#delete">X</button>
      </div>
    `);

    const row = document.querySelector('.row') as HTMLElement;
    row.querySelector('button')?.click();

    expect(document.querySelector('.row')).toBeNull();
  });

  it('marks persisted rows for removal and restores them on a second click', async () => {
    await renderRecords(`
      <div class="row" data-controller="dynamic-list-record">
        <input type="hidden" data-dynamic-list-record-target="destroy" value="0" />
        <input id="question" name="question" />
        <button type="button" data-dynamic-list-record-target="deleteButton"
                data-action="click->dynamic-list-record#delete">X</button>
      </div>
    `);

    const row = document.querySelector('.row') as HTMLElement;
    const button = row.querySelector('button') as HTMLButtonElement;

    button.click();
    expect(row.hasAttribute('data-remove')).toBe(true);
    expect((row.querySelector('[data-dynamic-list-record-target="destroy"]') as HTMLInputElement).value).toBe('1');

    button.click();
    expect(row.hasAttribute('data-remove')).toBe(false);
    expect((row.querySelector('[data-dynamic-list-record-target="destroy"]') as HTMLInputElement).value).toBe('0');
  });

  it('marks the row for removal on load when _destroy is already set', async () => {
    await renderRecords(`
      <div class="row" data-controller="dynamic-list-record">
        <input type="hidden" data-dynamic-list-record-target="destroy" value="1" />
        <button type="button" data-dynamic-list-record-target="deleteButton"
                data-action="click->dynamic-list-record#delete">X</button>
      </div>
    `);

    expect(document.querySelector('.row')?.hasAttribute('data-remove')).toBe(true);
  });
});
