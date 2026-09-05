import { Controller } from '@hotwired/stimulus';

export default class DynamicListRecordController extends Controller<HTMLElement> {
  static override targets = ['destroy'];

  declare readonly hasDestroyTarget: boolean;
  declare readonly destroyTarget: HTMLInputElement;

  override connect(): void {
    if (this.hasDestroyTarget && this.destroyTarget.value === '1') {
      this.element.toggleAttribute('data-remove', true);
    }
  }

  delete(event: Event): void {
    event.preventDefault();

    if (!this.hasDestroyTarget) {
      const parent = this.element.parentElement;
      this.element.remove();
      if (parent != null) {
        this.dispatch('changed', { target: parent });
      }
      return;
    }

    const removed = !this.element.hasAttribute('data-remove');
    this.element.toggleAttribute('data-remove', removed);
    this.destroyTarget.value = removed ? '1' : '0';
    this.dispatch('changed');
  }
}
