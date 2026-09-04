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

  function deleteButtonFor(rowId: string): HTMLButtonElement {
    return document.querySelector(`[data-dynamic-target-id="${rowId}"]`) as HTMLButtonElement;
  }

  it('removes non-persisted rows from the DOM', async () => {
    await renderRecords(`
      <div class="row" id="row-1" data-controller="dynamic-list-record" data-persisted="false">
        <button type="button" class="dynamic-list-delete"
                data-dynamic-target-id="row-1"
                data-action="click->dynamic-list-record#delete">X</button>
      </div>
    `);

    deleteButtonFor('row-1').click();

    expect(document.querySelector('#row-1')).toBeNull();
  });

  it('marks persisted rows for removal and restores them on a second click', async () => {
    await renderRecords(`
      <div class="row" id="poll_1" data-controller="dynamic-list-record" data-persisted="true">
        <input type="hidden" class="destroy" value="0" />
        <input id="question" name="question" />
        <button type="button" class="dynamic-list-delete btn btn-danger"
                data-dynamic-target-id="poll_1"
                data-action="click->dynamic-list-record#delete">X</button>
      </div>
    `);

    const row = document.querySelector('#poll_1') as HTMLElement;
    const question = row.querySelector('#question') as HTMLInputElement;
    const button = deleteButtonFor('poll_1');

    button.click();
    expect(row.hasAttribute('data-remove')).toBe(true);
    expect((row.querySelector('input.destroy') as HTMLInputElement).value).toBe('1');
    expect(question.disabled).toBe(true);
    expect(question.classList.contains('text-decoration-line-through')).toBe(true);
    expect(button.textContent).toBe('+');
    expect(button.classList.contains('btn-primary')).toBe(true);
    expect(button.classList.contains('btn-danger')).toBe(false);

    button.click();
    expect(row.hasAttribute('data-remove')).toBe(false);
    expect((row.querySelector('input.destroy') as HTMLInputElement).value).toBe('0');
    expect(question.disabled).toBe(false);
    expect(question.classList.contains('text-decoration-line-through')).toBe(false);
    expect(button.textContent).toBe('X');
    expect(button.classList.contains('btn-danger')).toBe(true);
    expect(button.classList.contains('btn-primary')).toBe(false);
  });

  function nestedRowsHtml(outerAttributes = '', outerDestroyValue = '0') {
    return `
      <div class="row" id="poll_1" data-controller="dynamic-list-record" data-persisted="true" ${outerAttributes}>
        <input type="hidden" class="destroy" value="${outerDestroyValue}" />
        <button type="button" class="dynamic-list-delete"
                data-dynamic-target-id="poll_1"
                data-action="click->dynamic-list-record#delete">X</button>
        <div class="responses">
          <div class="row" id="response_1" data-controller="dynamic-list-record" data-persisted="true">
            <input type="hidden" class="destroy" value="0" />
            <button type="button" class="dynamic-list-delete"
                    data-dynamic-target-id="response_1"
                    data-action="click->dynamic-list-record#delete">X</button>
          </div>
        </div>
      </div>
    `;
  }

  it('disables nested delete buttons while marked for removal', async () => {
    await renderRecords(nestedRowsHtml());

    const pollButton = deleteButtonFor('poll_1');
    const responseButton = deleteButtonFor('response_1');

    pollButton.click();
    expect(responseButton.disabled).toBe(true);
    expect(pollButton.disabled).toBe(false);

    pollButton.click();
    expect(responseButton.disabled).toBe(false);
  });

  it('disables nested delete buttons on load when the row is already marked for destruction', async () => {
    await renderRecords(nestedRowsHtml('', '1'));

    expect(deleteButtonFor('response_1').disabled).toBe(true);
  });

  it('disables the delete button for rows under an ancestor marked for removal', async () => {
    await renderRecords(nestedRowsHtml('data-remove'));

    expect(deleteButtonFor('response_1').disabled).toBe(true);
  });
});
