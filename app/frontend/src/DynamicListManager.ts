import $ from 'jquery';

import type { MaybeJQ } from '@/types.js';
import DynamicListRecord from './DynamicListRecord.js';

class DynamicListManager {
  addButton: JQuery<HTMLElement>;
  targetElement: JQuery<HTMLElement>;
  prependTemplate: string;
  childIndexPlaceholder: string;
  recordLimit: number;

  constructor(addButton: MaybeJQ<HTMLElement>) {
    this.addButton = $(addButton);
    if (this.addButton.length === 0) {
      throw new Error('DynamicListManager: add button element is missing or not in the document.');
    }

    const idLabel = this.addButton.attr('id');
    const buttonRef = idLabel != null && idLabel !== '' ? ` #${idLabel}` : '';

    this.recordLimit = this.addButton.data('record-limit');
    this.targetElement = $(this.addButton.data('target'));

    this.prependTemplate = this.addButton.data('form-prepend');
    if (this.prependTemplate == null) {
      throw new Error(`No data-form-prepend attribute found on record add button ${buttonRef}. This is necessary to add new records.`);
    }

    this.childIndexPlaceholder = this.addButton.data('prepend-child-index');
    if (this.childIndexPlaceholder == null) {
      throw new Error(`No data-prepend-child-index attribute found on record add button${buttonRef}. This is necessary to properly template new records.`);
    }

    this.addButton.on('click', () => {
      const recordElement = DynamicListRecord.fromTemplate(this.prependTemplate, this.childIndexPlaceholder, this.enforceListLimit.bind(this)).element;
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

/** Binds DynamicListManager for every `[data-form-prepend]` under `root` (use `document` for full page; a row element after inserting HTML). */
export function initializeDynamicListManagersWithin(root: MaybeJQ<HTMLElement> | Document) {
  $(root).find('[data-form-prepend]').each((_, button) => {
    ensureDynamicListManager(button);
  });
}