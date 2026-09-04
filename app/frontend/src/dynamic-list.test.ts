import { describe, it, expect } from 'vitest';

import { stampRowFromTemplate } from './dynamic-list.js';

function templateFromHTML(html: string) {
  const template = document.createElement('template');
  template.innerHTML = html.trim();
  return template;
}

describe('stampRowFromTemplate', () => {
  it('replaces child index placeholders in name and id attributes', () => {
    const template = templateFromHTML(`
      <div id="record_CHILD_INDEX_">
        <input id="field_CHILD_INDEX_" name="event[polls_attributes][CHILD_INDEX_][question]" />
        <label for="field_CHILD_INDEX_">Question</label>
      </div>
    `);

    const fragment = stampRowFromTemplate(template, 'CHILD_INDEX_');
    const row = fragment.firstElementChild as HTMLElement;
    const input = row.querySelector('input') as HTMLInputElement;

    expect(input.getAttribute('name')).toMatch(/event\[polls_attributes\]\[[0-9a-f-]+\]\[question\]/);
    expect(input.getAttribute('name')).not.toContain('CHILD_INDEX_');
    expect(row.id).not.toContain('CHILD_INDEX_');
    expect(input.id).toBe(row.querySelector('label')?.getAttribute('for'));
  });

  it('replaces placeholders inside nested template content and attaches nested shadow roots', () => {
    const template = templateFromHTML(`
      <div id="poll__timestamp_">
        <input name="event[polls_attributes][added_poll][question]" />
        <span data-controller="dynamic-list"
              data-dynamic-list-child-index-value="added_response"
              data-dynamic-list-target-value=".example-responses-poll__timestamp_">
          <template shadowrootmode="open" shadowrootclonable>
            <template>
              <input name="event[polls_attributes][added_poll][responses_attributes][added_response][choice]" />
            </template>
            <slot></slot>
          </template>
          Add option
        </span>
      </div>
    `);

    const fragment = stampRowFromTemplate(template, 'added_poll');
    const row = fragment.firstElementChild as HTMLElement;
    const nestedAddButton = row.querySelector('[data-controller="dynamic-list"]') as HTMLElement;

    const nestedTemplate = [...(nestedAddButton.shadowRoot?.children ?? [])]
      .find((el): el is HTMLTemplateElement => el instanceof HTMLTemplateElement);
    expect(nestedTemplate).toBeInstanceOf(HTMLTemplateElement);
    const nestedName = nestedTemplate?.content.querySelector('input')?.getAttribute('name');
    expect(nestedName).toMatch(/event\[polls_attributes\]\[[0-9a-f-]+\]\[responses_attributes\]\[added_response\]\[choice\]/);
    expect(nestedName).not.toContain('added_poll');
    expect(nestedAddButton.getAttribute('data-dynamic-list-target-value')).not.toContain('_timestamp_');
  });
});
