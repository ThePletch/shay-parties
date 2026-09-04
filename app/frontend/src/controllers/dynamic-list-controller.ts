import { Controller } from '@hotwired/stimulus';

import { attachDeclarativeShadowRoot, stampRowFromTemplate } from '@/dynamic-list.js';
import { RECORD_CHANGED_EVENT } from './dynamic-list-record-controller.js';

export default class DynamicListController extends Controller<HTMLElement> {
  static override values = {
    childIndex: String,
    target: String,
    recordLimit: { type: Number, default: -1 },
  };

  declare readonly childIndexValue: string;
  declare readonly targetValue: string;
  declare readonly recordLimitValue: number;

  private rowTemplate!: HTMLTemplateElement;
  private listContainer!: Element;

  override connect(): void {
    if (this.childIndexValue === '') {
      throw new Error(`No data-dynamic-list-child-index-value attribute found on record add button${this.idLabel}. This is necessary to properly template new records.`);
    }

    this.rowTemplate = this.resolveRowTemplate();
    this.listContainer = this.resolveContainer();
    this.listContainer.addEventListener(RECORD_CHANGED_EVENT, this.enforceListLimit);
    this.enforceListLimit();
  }

  override disconnect(): void {
    this.listContainer?.removeEventListener(RECORD_CHANGED_EVENT, this.enforceListLimit);
  }

  add(event: Event): void {
    event.preventDefault();
    this.listContainer.append(stampRowFromTemplate(this.rowTemplate, this.childIndexValue));
    this.enforceListLimit();
  }

  private get idLabel(): string {
    return this.element.id !== '' ? ` #${this.element.id}` : '';
  }

  private resolveRowTemplate(): HTMLTemplateElement {
    const shadow = attachDeclarativeShadowRoot(this.element) ?? this.element.shadowRoot;
    const template = [...(shadow?.children ?? [])].find((el): el is HTMLTemplateElement => el instanceof HTMLTemplateElement);
    if (template == null) {
      throw new Error(`No row <template> found in the shadow root of record add button${this.idLabel}. This is necessary to add new records.`);
    }

    return template;
  }

  private resolveContainer(): Element {
    const container = document.querySelector(this.targetValue);
    if (container == null) {
      throw new Error(`No element matching "${this.targetValue}" found for record add button${this.idLabel}. This is necessary to add new records.`);
    }

    return container;
  }

  // Disable/enable the add button depending on whether we're at the record limit
  private enforceListLimit = (): void => {
    if (this.recordLimitValue < 0) {
      return;
    }

    const unremovedCount = [...this.listContainer.children].filter((el) => !el.hasAttribute('data-remove')).length;
    this.element.classList.toggle('disabled', unremovedCount >= this.recordLimitValue);
  };
}
