import { describe, it, expect } from 'vitest';

import { stampRowFromTemplate } from './dynamic-list.js';

function templateFromHTML(html: string) {
  const template = document.createElement('template');
  template.innerHTML = html.trim();
  return template;
}

describe('stampRowFromTemplate', () => {
  it('replaces child index placeholders in attributes', () => {
    const template = templateFromHTML(`
      <div>
        <input id="field_new_polls" name="event[polls_attributes][new_polls][question]" />
        <label for="field_new_polls">Question</label>
      </div>
    `);

    const fragment = stampRowFromTemplate(template, 'new_polls');
    const row = fragment.firstElementChild as HTMLElement;
    const input = row.querySelector('input') as HTMLInputElement;

    expect(input.getAttribute('name')).toMatch(/event\[polls_attributes\]\[\d+\]\[question\]/);
    expect(input.getAttribute('name')).not.toContain('new_polls');
    expect(input.id).toBe(row.querySelector('label')?.getAttribute('for'));
    expect(input.id).not.toContain('new_polls');
  });

  it('replaces the parent placeholder inside nested templates and leaves the child placeholder', () => {
    const template = templateFromHTML(`
      <div>
        <input name="event[polls_attributes][new_polls][question]" />
        <div data-controller="dynamic-list" data-dynamic-list-child-index-value="new_options">
          <template data-dynamic-list-target="template">
            <input name="event[polls_attributes][new_polls][options_attributes][new_options][choice]" />
          </template>
          <div data-dynamic-list-target="rows"></div>
          <button type="button" data-dynamic-list-target="addButton">Add option</button>
        </div>
      </div>
    `);

    const fragment = stampRowFromTemplate(template, 'new_polls');
    const row = fragment.firstElementChild as HTMLElement;
    const nestedTemplate = row.querySelector('template') as HTMLTemplateElement;
    const nestedName = nestedTemplate.content.querySelector('input')?.getAttribute('name');

    expect(nestedName).toMatch(/event\[polls_attributes\]\[\d+\]\[options_attributes\]\[new_options\]\[choice\]/);
    expect(nestedName).not.toContain('new_polls');
    expect(nestedName).toContain('new_options');
  });
});
