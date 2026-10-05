import { describe, expect, it } from 'vitest';

import { initRsvpChoice } from './rsvp-choice.js';

function formFromHTML(html: string): HTMLFormElement {
  document.body.innerHTML = html;
  const form = document.querySelector('form');
  if (!form) {
    throw new Error('missing form');
  }
  return form;
}

describe('initRsvpChoice', () => {
  it('keeps name and email hidden until a guest selects a response', () => {
    const form = formFromHTML(`
      <form data-rsvp-choice="true">
        <input type="radio" name="attendance[rsvp_status]" value="Yes" />
        <input type="radio" name="attendance[rsvp_status]" value="Maybe" />
        <div data-rsvp-identity="pending" hidden>
          <input id="name" />
          <button type="submit" data-rsvp-submit-label data-label-yes="RSVP going" data-label-maybe="RSVP maybe" data-label-no="Can’t come">RSVP going</button>
        </div>
      </form>
    `);

    initRsvpChoice();
    const identity = form.querySelector<HTMLElement>('[data-rsvp-identity]')!;
    const submit = form.querySelector('button')!;

    expect(identity.hidden).toBe(true);

    const going = form.querySelector<HTMLInputElement>('input[value="Yes"]')!;
    going.checked = true;
    going.dispatchEvent(new Event('change'));

    expect(identity.hidden).toBe(false);
    expect(submit.textContent).toBe('RSVP going');

    const maybe = form.querySelector<HTMLInputElement>('input[value="Maybe"]')!;
    maybe.checked = true;
    maybe.dispatchEvent(new Event('change'));

    expect(submit.textContent).toBe('RSVP maybe');
  });

  it('submits immediately when the guest is already known', () => {
    const form = formFromHTML(`
      <form data-rsvp-choice="true" data-rsvp-autosubmit="true">
        <input type="radio" name="attendance[rsvp_status]" value="Yes" checked />
        <input type="radio" name="attendance[rsvp_status]" value="No" />
      </form>
    `);
    let submitted = false;
    form.requestSubmit = () => {
      submitted = true;
    };

    initRsvpChoice();
    expect(submitted).toBe(false);

    const declining = form.querySelector<HTMLInputElement>('input[value="No"]')!;
    declining.checked = true;
    declining.dispatchEvent(new Event('change'));

    expect(submitted).toBe(true);
  });

  it('reveals saved guest fields when editing identity', () => {
    const form = formFromHTML(`
      <form data-rsvp-choice="true" data-rsvp-autosubmit="true">
        <input type="radio" name="attendance[rsvp_status]" value="Yes" checked />
        <p data-rsvp-identity-summary>Maya Chen · maya@example.com</p>
        <button type="button" data-rsvp-edit-identity>Edit</button>
        <div data-rsvp-identity="saved" hidden>
          <input id="name" value="Maya Chen" />
        </div>
      </form>
    `);

    initRsvpChoice();
    const identity = form.querySelector<HTMLElement>('[data-rsvp-identity]')!;
    expect(identity.hidden).toBe(true);

    form.querySelector<HTMLButtonElement>('[data-rsvp-edit-identity]')!.click();

    expect(identity.hidden).toBe(false);
    expect(form.querySelector<HTMLElement>('[data-rsvp-identity-summary]')!.hidden).toBe(true);
  });
});
