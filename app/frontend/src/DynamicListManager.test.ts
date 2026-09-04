import { describe, it, expect, beforeEach } from 'vitest';
import { initializeDynamicListManagersWithin } from './DynamicListManager.js';

describe('DynamicListManager', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div id="polls"></div>
      <span id="add-poll" class="btn" data-prepend-child-index="added_poll" data-target="#polls">
        <template shadowrootmode="open" shadowrootclonable>
          <template>
            <div class="row" id="poll__timestamp_">
              <input name="event[polls_attributes][added_poll][question]" />
            </div>
          </template>
          <slot></slot>
        </template>
        Add poll
      </span>
    `;
  });

  it('stamps a row with unique ids from the shadow template instead of a data attribute', () => {
    initializeDynamicListManagersWithin(document);

    const addButton = document.querySelector('#add-poll') as HTMLElement;
    expect(addButton.getAttribute('data-form-prepend')).toBeNull();
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
});
