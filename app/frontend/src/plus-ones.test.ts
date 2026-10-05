import { describe, expect, it } from 'vitest';

import { initPlusOnes } from './plus-ones.js';

function sectionFromHTML(html: string): HTMLElement {
  document.body.innerHTML = html;
  const section = document.querySelector<HTMLElement>('.rsvp-plus-ones');
  if (!section) {
    throw new Error('missing plus-ones section');
  }
  return section;
}

describe('initPlusOnes', () => {
  it('discards edits and returns to the summary', () => {
    const section = sectionFromHTML(`
      <div class="rsvp-plus-ones" data-plus-ones-mode="form">
        <p data-plus-one-summary>Sam · sam@example.com</p>
        <div data-dynamic-list-target="rows">
          <div data-controller="dynamic-list-record" data-remove>
            <input type="hidden" data-dynamic-list-record-target="destroy" value="1" />
            <input type="text" value="Renamed" />
          </div>
          <div data-controller="dynamic-list-record">
            <input type="text" value="New person" />
          </div>
        </div>
        <button type="button" data-plus-ones-cancel>Cancel</button>
      </div>
    `);
    const kept = section.querySelector<HTMLInputElement>('[data-dynamic-list-record-target="destroy"]')!
      .parentElement!.querySelector<HTMLInputElement>('input[type="text"]')!;
    kept.defaultValue = 'Sam';

    initPlusOnes();
    section.querySelector<HTMLButtonElement>('[data-plus-ones-cancel]')!.click();

    expect(section.dataset.plusOnesMode).toBe('summary');
    expect(section.querySelectorAll('[data-controller~="dynamic-list-record"]')).toHaveLength(1);
    expect(kept.value).toBe('Sam');
    expect(section.querySelector<HTMLInputElement>('[data-dynamic-list-record-target="destroy"]')!.value).toBe('0');
    expect(section.querySelector('[data-remove]')).toBeNull();
  });
});
