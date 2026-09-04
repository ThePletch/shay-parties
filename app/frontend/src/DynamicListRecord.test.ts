import { describe, it, expect, vi } from 'vitest';
import $ from 'jquery';
import DynamicListRecord from './DynamicListRecord.js';

function templateFromHTML(html: string) {
  const template = document.createElement('template');
  template.innerHTML = html.trim();
  return template;
}

describe('DynamicListRecord.fromTemplate', () => {
  it('replaces child index placeholders in name and id attributes', () => {
    const template = templateFromHTML(`
      <div id="record_CHILD_INDEX_">
        <input id="field_CHILD_INDEX_" name="event[polls_attributes][CHILD_INDEX_][question]" />
        <label for="field_CHILD_INDEX_">Question</label>
      </div>
    `);

    const record = DynamicListRecord.fromTemplate(
      template,
      'CHILD_INDEX_',
      vi.fn(),
    );

    const name = record.element.find('input').attr('name');
    expect(name).toMatch(/event\[polls_attributes\]\[[0-9a-f-]+\]\[question\]/);
    expect(name).not.toContain('CHILD_INDEX_');
    expect(record.element.attr('id')).not.toContain('CHILD_INDEX_');
    expect(record.element.find('input').attr('id')).toBe(record.element.find('label').attr('for'));
  });

  it('replaces placeholders inside nested template content', () => {
    const template = templateFromHTML(`
      <div id="poll__timestamp_">
        <input name="event[polls_attributes][added_poll][question]" />
        <span data-prepend-child-index="added_response" data-target=".example-responses-poll__timestamp_">
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

    const record = DynamicListRecord.fromTemplate(template, 'added_poll', vi.fn());

    const nestedTemplate = [...(record.element.find('[data-prepend-child-index]')[0]?.shadowRoot?.children ?? [])]
      .find((el): el is HTMLTemplateElement => el instanceof HTMLTemplateElement);
    expect(nestedTemplate).toBeInstanceOf(HTMLTemplateElement);
    const nestedName = (nestedTemplate as HTMLTemplateElement).content.querySelector('input')?.getAttribute('name');
    expect(nestedName).toMatch(/event\[polls_attributes\]\[[0-9a-f-]+\]\[responses_attributes\]\[added_response\]\[choice\]/);
    expect(nestedName).not.toContain('added_poll');
    expect(record.element.find('[data-prepend-child-index]').attr('data-target')).not.toContain('_timestamp_');
  });
});

describe('DynamicListRecord delete button', () => {
  it('removes non-persisted rows from the DOM', () => {
    document.body.innerHTML = `
      <div id="row-1" data-persisted="false">
        <button class="dynamic-list-delete" data-dynamic-target-id="row-1">X</button>
      </div>
    `;

    const record = new DynamicListRecord($('#row-1'));
    record.element.find('.dynamic-list-delete').trigger('click');

    expect($('#row-1').length).toBe(0);
  });
});
