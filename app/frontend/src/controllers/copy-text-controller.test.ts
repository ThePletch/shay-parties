import { describe, it, expect, afterEach, vi } from 'vitest';
import type { Application } from '@hotwired/stimulus';

import CopyTextController from './copy-text-controller.js';
import { startStimulusWith } from '../../test/stimulus.js';

describe('CopyTextController', () => {
  let application: Application | null = null;

  afterEach(() => {
    application?.stop();
    application = null;
    vi.unstubAllGlobals();
  });

  async function render(): Promise<HTMLElement> {
    document.body.innerHTML = `
      <div data-controller="copy-text"
           data-copy-text-message-value="Copied 2 addresses"
           data-copy-text-failed-value="Could not copy">
        <textarea class="d-none" aria-hidden="true" data-copy-text-target="source">maya@example.com
jordan@example.com</textarea>
        <button type="button" data-action="copy-text#copy">Copy addresses</button>
        <span data-copy-text-target="status"></span>
      </div>
    `;
    application = await startStimulusWith({ 'copy-text': CopyTextController });
    return document.querySelector('[data-controller="copy-text"]') as HTMLElement;
  }

  it('copies the addresses and reports how many', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    vi.stubGlobal('navigator', { clipboard: { writeText } });
    const root = await render();

    root.querySelector('button')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await Promise.resolve();
    await Promise.resolve();

    expect(writeText).toHaveBeenCalledWith('maya@example.com\njordan@example.com');
    expect(root.querySelector('[data-copy-text-target="status"]')?.textContent).toBe('Copied 2 addresses');
  });

  it('shows the addresses when the clipboard is unavailable', async () => {
    vi.stubGlobal('navigator', {});
    const root = await render();

    root.querySelector('button')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await Promise.resolve();

    const source = root.querySelector('textarea');
    expect(source?.classList.contains('d-none')).toBe(false);
    expect(root.querySelector('[data-copy-text-target="status"]')?.textContent).toBe('Could not copy');
  });
});
