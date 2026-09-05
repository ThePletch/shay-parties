import { describe, it, expect, afterEach } from 'vitest';
import type { Application } from '@hotwired/stimulus';

import DynamicListController from './dynamic-list-controller.js';
import DynamicListRecordController from './dynamic-list-record-controller.js';
import { startStimulusWith, waitForController } from '../../test/stimulus.js';

describe('DynamicListController', () => {
  let application: Application | null = null;

  afterEach(() => {
    application?.stop();
    application = null;
  });

  async function renderList(listHtml: string): Promise<Application> {
    document.body.innerHTML = listHtml;
    application = await startStimulusWith({
      'dynamic-list': DynamicListController,
      'dynamic-list-record': DynamicListRecordController,
    });
    return application;
  }

  function listHtml(rows = '', extraValues = '') {
    return `
      <div data-controller="dynamic-list"
           data-action="dynamic-list-record:changed->dynamic-list#enforceLimit"
           data-dynamic-list-child-index-value="new_polls"
           ${extraValues}>
        <template data-dynamic-list-target="template">
          <div class="row" data-controller="dynamic-list-record">
            <input name="event[polls_attributes][new_polls][question]" />
            <button type="button" data-dynamic-list-record-target="deleteButton"
                    data-action="click->dynamic-list-record#delete">X</button>
          </div>
        </template>
        <div data-dynamic-list-target="rows">${rows}</div>
        <button type="button" data-dynamic-list-target="addButton"
                data-action="click->dynamic-list#add">Add poll</button>
      </div>
    `;
  }

  it('stamps rows with unique indexes from the template', async () => {
    await renderList(listHtml());

    const addButton = document.querySelector('[data-dynamic-list-target="addButton"]') as HTMLButtonElement;
    addButton.click();
    addButton.click();

    const rows = document.querySelectorAll('[data-dynamic-list-target="rows"] .row');
    expect(rows).toHaveLength(2);

    const names = [...rows].map((row) => row.querySelector('input')?.getAttribute('name'));
    expect(names[0]).not.toBe(names[1]);
    expect(names[0]).toMatch(/event\[polls_attributes\]\[\d+\]\[question\]/);
    expect(names[1]).toMatch(/event\[polls_attributes\]\[\d+\]\[question\]/);
  });

  it('disables the add button at the record limit and re-enables it when a row is deleted', async () => {
    const app = await renderList(listHtml('', 'data-dynamic-list-record-limit-value="1"'));

    const addButton = document.querySelector('[data-dynamic-list-target="addButton"]') as HTMLButtonElement;
    expect(addButton.disabled).toBe(false);

    addButton.click();
    expect(addButton.disabled).toBe(true);

    const row = document.querySelector('[data-dynamic-list-target="rows"] .row') as HTMLElement;
    await waitForController(app, row, 'dynamic-list-record');
    const deleteButton = row.querySelector('[data-dynamic-list-record-target="deleteButton"]') as HTMLElement;
    deleteButton.click();

    expect(document.querySelectorAll('[data-dynamic-list-target="rows"] .row')).toHaveLength(0);
    expect(addButton.disabled).toBe(false);
  });

  it('does not count rows marked for removal against the record limit', async () => {
    await renderList(listHtml(`
      <div class="row" data-controller="dynamic-list-record">
        <input type="hidden" data-dynamic-list-record-target="destroy" value="0" />
        <input name="event[polls_attributes][1][question]" />
        <button type="button" data-dynamic-list-record-target="deleteButton"
                data-action="click->dynamic-list-record#delete">X</button>
      </div>
    `, 'data-dynamic-list-record-limit-value="1"'));

    const addButton = document.querySelector('[data-dynamic-list-target="addButton"]') as HTMLButtonElement;
    expect(addButton.disabled).toBe(true);

    const deleteButton = document.querySelector('[data-dynamic-list-record-target="deleteButton"]') as HTMLElement;
    deleteButton.click();
    expect(addButton.disabled).toBe(false);

    deleteButton.click();
    expect(addButton.disabled).toBe(true);
  });
});
