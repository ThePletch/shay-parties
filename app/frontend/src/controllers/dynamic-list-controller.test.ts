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

  function addButtonHtml(extraAttributes = '') {
    return `
      <span id="add-poll" class="btn"
            data-controller="dynamic-list"
            data-action="click->dynamic-list#add"
            data-dynamic-list-child-index-value="added_poll"
            data-dynamic-list-target-value="#polls"
            ${extraAttributes}>
        <template shadowrootmode="open" shadowrootclonable>
          <template>
            <div class="row" id="poll__timestamp_" data-controller="dynamic-list-record" data-persisted="false">
              <input name="event[polls_attributes][added_poll][question]" />
              <button type="button" class="dynamic-list-delete"
                      data-dynamic-target-id="poll__timestamp_"
                      data-action="click->dynamic-list-record#delete">X</button>
            </div>
          </template>
          <slot></slot>
        </template>
        Add poll
      </span>
    `;
  }

  it('stamps rows with unique ids from the shadow template', async () => {
    await renderList(`
      <div id="polls"></div>
      ${addButtonHtml()}
    `);

    const addButton = document.querySelector('#add-poll') as HTMLElement;
    expect(
      [...(addButton.shadowRoot?.children ?? [])].find((el) => el instanceof HTMLTemplateElement),
    ).toBeInstanceOf(HTMLTemplateElement);

    addButton.click();
    addButton.click();

    const rows = document.querySelectorAll('#polls .row');
    expect(rows).toHaveLength(2);
    const ids = [...rows].map((row) => row.id);
    expect(ids[0]).not.toBe(ids[1]);
    expect(ids[0]).not.toContain('_timestamp_');
    expect(ids[1]).not.toContain('added_poll');

    const names = [...rows].map((row) => row.querySelector('input')?.getAttribute('name'));
    expect(names[0]).not.toBe(names[1]);
    expect(names[0]).not.toContain('added_poll');
  });

  it('disables the add button at the record limit and re-enables it when a row is deleted', async () => {
    const app = await renderList(`
      <div id="polls"></div>
      ${addButtonHtml('data-dynamic-list-record-limit-value="1"')}
    `);

    const addButton = document.querySelector('#add-poll') as HTMLElement;
    expect(addButton.classList.contains('disabled')).toBe(false);

    addButton.click();
    expect(addButton.classList.contains('disabled')).toBe(true);

    const row = document.querySelector('#polls .row') as HTMLElement;
    await waitForController(app, row, 'dynamic-list-record');
    const deleteButton = row.querySelector('.dynamic-list-delete') as HTMLElement;
    deleteButton.click();

    expect(document.querySelectorAll('#polls .row')).toHaveLength(0);
    expect(addButton.classList.contains('disabled')).toBe(false);
  });

  it('does not count rows marked for removal against the record limit', async () => {
    await renderList(`
      <div id="polls">
        <div class="row" id="poll_1" data-controller="dynamic-list-record" data-persisted="true">
          <input type="hidden" class="destroy" value="0" />
          <input name="event[polls_attributes][1][question]" />
          <button type="button" class="dynamic-list-delete"
                  data-dynamic-target-id="poll_1"
                  data-action="click->dynamic-list-record#delete">X</button>
        </div>
      </div>
      ${addButtonHtml('data-dynamic-list-record-limit-value="1"')}
    `);

    const addButton = document.querySelector('#add-poll') as HTMLElement;
    expect(addButton.classList.contains('disabled')).toBe(true);

    const deleteButton = document.querySelector('#polls .dynamic-list-delete') as HTMLElement;
    deleteButton.click();
    expect(addButton.classList.contains('disabled')).toBe(false);

    deleteButton.click();
    expect(addButton.classList.contains('disabled')).toBe(true);
  });
});
