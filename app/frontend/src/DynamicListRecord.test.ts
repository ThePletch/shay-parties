import { describe, it, expect, vi } from 'vitest';
import $ from 'jquery';
import DynamicListRecord from './DynamicListRecord.js';

describe('DynamicListRecord.fromTemplate', () => {
  it('replaces child index placeholders in name attributes', () => {
    const template = `
      <div id="record_CHILD_INDEX_">
        <input name="event[polls_attributes][CHILD_INDEX_][question]" />
      </div>
    `;

    const record = DynamicListRecord.fromTemplate(
      template,
      'CHILD_INDEX_',
      vi.fn(),
    );

    const name = record.element.find('input').attr('name');
    expect(name).toMatch(/event\[polls_attributes\]\[\d+\]\[question\]/);
    expect(name).not.toContain('CHILD_INDEX_');
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
