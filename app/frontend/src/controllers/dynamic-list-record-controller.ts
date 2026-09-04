import { Controller } from '@hotwired/stimulus';

export const RECORD_CHANGED_EVENT = 'dynamic-list-record:changed';

const MARKED_FOR_REMOVAL_ATTRIBUTE = 'data-remove';

export default class DynamicListRecordController extends Controller<HTMLElement> {
  override connect(): void {
    // Server-rendered rows may already have _destroy set (e.g. after validation).
    if (this.ownDestroyInput?.value === '1') {
      this.setNestedDeleteButtonsDisabled(true);
    }

    const deleteButton = this.ownDeleteButton;
    if (deleteButton != null && this.hasMarkedAncestorRow()) {
      deleteButton.disabled = true;
    }
  }

  delete(event: Event): void {
    event.preventDefault();

    if (!this.isPersisted) {
      const container = this.element.parentElement;
      this.element.remove();
      this.dispatch('changed', { target: container ?? this.element });
      return;
    }

    const nowMarked = !this.element.hasAttribute(MARKED_FOR_REMOVAL_ATTRIBUTE);
    this.element.toggleAttribute(MARKED_FOR_REMOVAL_ATTRIBUTE, nowMarked);
    for (const input of this.element.querySelectorAll<HTMLInputElement>('input:not([type="hidden"])')) {
      input.disabled = nowMarked;
    }
    for (const input of this.element.querySelectorAll<HTMLInputElement>('input.destroy')) {
      input.value = nowMarked ? '1' : '0';
    }
    this.setNestedDeleteButtonsDisabled(nowMarked);

    for (const input of this.element.querySelectorAll('input')) {
      input.classList.toggle('text-decoration-line-through', nowMarked);
    }
    const deleteButton = this.ownDeleteButton;
    if (deleteButton != null) {
      deleteButton.classList.toggle('btn-danger', !nowMarked);
      deleteButton.classList.toggle('btn-primary', nowMarked);
      deleteButton.textContent = nowMarked ? '+' : 'X';
    }

    this.dispatch('changed');
  }

  private get isPersisted(): boolean {
    return this.element.dataset['persisted'] === 'true';
  }

  /** This row's delete control (excludes nested list rows' buttons). */
  private get ownDeleteButton(): HTMLButtonElement | null {
    const candidates = [...this.element.querySelectorAll<HTMLButtonElement>('.dynamic-list-delete')];
    const matched = candidates.filter((el) => el.getAttribute('data-dynamic-target-id') === this.element.id);
    return matched[0] ?? candidates[0] ?? null;
  }

  /** Delete controls for nested list rows under this record (not this row's own button). */
  private nestedDeleteButtons(): HTMLButtonElement[] {
    if (this.element.id === '') {
      return [];
    }

    return [...this.element.querySelectorAll<HTMLButtonElement>('.dynamic-list-delete')]
      .filter((el) => el.getAttribute('data-dynamic-target-id') !== this.element.id);
  }

  private setNestedDeleteButtonsDisabled(disabled: boolean): void {
    for (const button of this.nestedDeleteButtons()) {
      button.disabled = disabled;
    }
  }

  private get ownDestroyInput(): HTMLInputElement | null {
    return this.element.querySelector('input.destroy');
  }

  /** List row wrappers use Bootstrap `.row`; a parent marked for removal disables nested delete actions. */
  private hasMarkedAncestorRow(): boolean {
    return this.element.parentElement?.closest(`.row[${MARKED_FOR_REMOVAL_ATTRIBUTE}]`) != null;
  }
}
