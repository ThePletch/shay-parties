import { Controller } from '@hotwired/stimulus';

export default class CopyTextController extends Controller<HTMLElement> {
  static override targets = ['source', 'status'];
  static override values = {
    message: String,
    failed: String,
  };

  declare readonly sourceTarget: HTMLTextAreaElement;
  declare readonly statusTarget: HTMLElement;
  declare readonly messageValue: string;
  declare readonly failedValue: string;

  async copy(event: Event): Promise<void> {
    event.preventDefault();
    const wrote = await this.writeToClipboard(this.sourceTarget.value);
    if (wrote) {
      this.statusTarget.textContent = this.messageValue;
      return;
    }

    this.sourceTarget.classList.remove('d-none');
    this.sourceTarget.removeAttribute('aria-hidden');
    this.statusTarget.textContent = this.failedValue;
  }

  private async writeToClipboard(text: string): Promise<boolean> {
    if (!navigator.clipboard?.writeText) {
      return false;
    }

    try {
      await navigator.clipboard.writeText(text);
      return true;
    } catch {
      return false;
    }
  }
}
