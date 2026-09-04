import $ from 'jquery';

import type { MaybeJQ } from '@/types.js';
import DynamicListRecord, { attachDeclarativeShadowRoot } from './DynamicListRecord.js';

const ADD_BUTTON_SELECTOR = '[data-prepend-child-index]';

function rowTemplateFrom(host: HTMLElement) {
  const shadow = attachDeclarativeShadowRoot(host) ?? host.shadowRoot;
  const template = [...(shadow?.children ?? [])].find((el): el is HTMLTemplateElement => el instanceof HTMLTemplateElement);
  if (!(template instanceof HTMLTemplateElement)) {
    const idLabel = host.id;
    const buttonRef = idLabel !== '' ? ` #${idLabel}` : '';
    throw new Error(`No row <template> found in the shadow root of record add button${buttonRef}. This is necessary to add new records.`);
  }

  return template;
}

class DynamicListManager {
  addButton: JQuery<HTMLElement>;
  targetElement: JQuery<HTMLElement>;
  rowTemplate: HTMLTemplateElement;
  childIndexPlaceholder: string;
  recordLimit: number;

  constructor(addButton: MaybeJQ<HTMLElement>) {
    this.addButton = $(addButton);
    if (this.addButton.length === 0) {
      throw new Error('DynamicListManager: add button element is missing or not in the document.');
    }

    const host = this.addButton.get(0);
    if (host == null) {
      throw new Error('DynamicListManager: add button element is missing or not in the document.');
    }

    const idLabel = this.addButton.attr('id');
    const buttonRef = idLabel != null && idLabel !== '' ? ` #${idLabel}` : '';

    this.recordLimit = this.addButton.data('record-limit');
    this.targetElement = $(this.addButton.data('target'));

    this.childIndexPlaceholder = this.addButton.data('prepend-child-index');
    if (this.childIndexPlaceholder == null) {
      throw new Error(`No data-prepend-child-index attribute found on record add button${buttonRef}. This is necessary to properly template new records.`);
    }

    this.rowTemplate = rowTemplateFrom(host);

    this.addButton.on('click', () => {
      const recordElement = DynamicListRecord.fromTemplate(this.rowTemplate, this.childIndexPlaceholder, this.enforceListLimit.bind(this)).element;
      this.targetElement.append(recordElement);
      initializeDynamicListManagersWithin(recordElement);
      this.enforceListLimit();
    });
    // initialize existing records as DynamicListRecords
    this.targetElement.children().each((_, childElement) => { new DynamicListRecord($(childElement), this.enforceListLimit.bind(this)); });

    this.enforceListLimit();
  }

  // Disable/enable the add button depending on whether we're at the record limit
  enforceListLimit() {
    if (this.recordLimit == null || this.recordLimit == -1) {
      // don't enforce the limit if the record limit is either not specified or set to -1 (unlimited)
      return;
    }

    const currentUnremovedElementCount = this.targetElement.children().filter((_, e) => !$(e).data('remove')).length;
    if (currentUnremovedElementCount >= this.recordLimit) {
      this.addButton.addClass('disabled');
    } else {
      this.addButton.removeClass('disabled');
    }
  }
}

function ensureDynamicListManager(button: HTMLElement) {
  const $button = $(button);
  if ($button.data('dynamicListManagerBound')) {
    return;
  }
  $button.data('dynamicListManagerBound', true);
  new DynamicListManager(button);
}

/** Binds DynamicListManager for every add control under `root` (use `document` for full page; a row element after inserting HTML). */
export function initializeDynamicListManagersWithin(root: MaybeJQ<HTMLElement> | Document) {
  $(root).find(ADD_BUTTON_SELECTOR).each((_, button) => {
    ensureDynamicListManager(button);
  });
}
