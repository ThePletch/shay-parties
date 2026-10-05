import { describe, it, expect, afterEach, vi } from 'vitest';
import type { Application } from '@hotwired/stimulus';

import ConfirmController from './confirm-controller.js';
import { startStimulusWith } from '../../test/stimulus.js';

describe('ConfirmController', () => {
  let application: Application | null = null;

  afterEach(() => {
    application?.stop();
    application = null;
    vi.unstubAllGlobals();
  });

  it('cancels the submit when the confirmation is declined', async () => {
    vi.stubGlobal('confirm', vi.fn().mockReturnValue(false));
    document.body.innerHTML = `
      <form data-controller="confirm" data-action="submit->confirm#guard" data-confirm-message-value="Delete this list?">
        <button type="submit">Delete list</button>
      </form>
    `;
    application = await startStimulusWith({ confirm: ConfirmController });
    const form = document.querySelector('form') as HTMLFormElement;
    const event = new Event('submit', { bubbles: true, cancelable: true });
    form.dispatchEvent(event);

    expect(confirm).toHaveBeenCalledWith('Delete this list?');
    expect(event.defaultPrevented).toBe(true);
  });
});
