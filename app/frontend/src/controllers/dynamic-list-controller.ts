import { Controller } from '@hotwired/stimulus';

import { stampRowFromTemplate } from '@/dynamic-list.js';

export default class DynamicListController extends Controller<HTMLElement> {
  static override targets = ['template', 'rows', 'addButton'];
  static override values = {
    childIndex: { type: String, default: 'new_record' },
    recordLimit: { type: Number, default: -1 },
  };

  declare readonly templateTarget: HTMLTemplateElement;
  declare readonly rowsTarget: HTMLElement;
  declare readonly addButtonTarget: HTMLButtonElement;
  declare readonly hasAddButtonTarget: boolean;
  declare readonly childIndexValue: string;
  declare readonly recordLimitValue: number;

  override connect(): void {
    this.enforceLimit();
  }

  add(event: Event): void {
    event.preventDefault();
    this.rowsTarget.append(stampRowFromTemplate(this.templateTarget, this.childIndexValue));
    this.enforceLimit();
  }

  enforceLimit(): void {
    if (this.recordLimitValue < 0 || !this.hasAddButtonTarget) {
      return;
    }

    const unremovedCount = [...this.rowsTarget.children].filter((el) => !el.hasAttribute('data-remove')).length;
    this.addButtonTarget.disabled = unremovedCount >= this.recordLimitValue;
  }
}
