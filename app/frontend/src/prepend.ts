import $ from 'jquery';

type MaybeJQ<T> = T | JQuery<T>;

export class DynamicListRecord {
  element: JQuery<HTMLElement>;

  static fromTemplate(template: string, childIndexPlaceholder: string, deleteHook: (eventName: string) => void) {
    const element = $(template);

    const timestamp = (new Date()).getTime();

    const replacePlaceholdersWithTimestamp = (element: MaybeJQ<HTMLElement>) => {
      const jqElement = $(element);
      Object.entries({
        [childIndexPlaceholder]: ['name', 'for', 'data-form-prepend'],
        '_timestamp_': ['class', 'data-target'],
      }).forEach(([placeholder, attrs]) => {
        attrs.forEach((attr) => {
          jqElement.attr(attr, () => {
            const currentAttr = jqElement.attr(attr);
            if (currentAttr != null) {
              return currentAttr.replaceAll(placeholder, timestamp.toString());
            }

            return undefined;
          });
        });
      });
    };

    element.find('*').each((_, element) => replacePlaceholdersWithTimestamp(element));
    replacePlaceholdersWithTimestamp(element);

    return new DynamicListRecord(element, deleteHook);
  }

  constructor(element: MaybeJQ<HTMLElement>, private deleteHook?: (eventName: string) => void) {
    this.element = $(element);
    this.initializeDeleteButton();
    this.syncNestedDeleteButtonsIfMarkedOnLoad();
    this.syncOwnDeleteButtonIfAncestorMarked();
  }

  /** This row's delete control (excludes nested list rows' buttons). */
  private resolveOwnDeleteButton(): JQuery<HTMLElement> {
    const rowId = this.element.attr('id');
    const candidates = this.element.find('.dynamic-list-delete');
    const matched =
      rowId != null && rowId !== ''
        ? candidates.filter((_, el) => $(el).attr('data-dynamic-target-id') === rowId)
        : $();

    return matched.length > 0 ? matched : candidates.first();
  }

  /** List row wrappers use Bootstrap `.row`; parent marked for removal disables nested delete actions. */
  private hasMarkedAncestorRowForRemoval(): boolean {
    return this.element.parents('.row').get().some((ancestor) => Boolean($(ancestor).data('remove')));
  }

  private syncOwnDeleteButtonIfAncestorMarked() {
    if (!this.hasMarkedAncestorRowForRemoval()) {
      return;
    }

    const $btn = this.resolveOwnDeleteButton();
    if ($btn.length > 0) {
      $btn.prop('disabled', true);
    }
  }

  /** Delete controls for nested list rows under this record (not this row's own button). */
  private nestedDynamicListDeleteButtons(): JQuery<HTMLElement> {
    const rowId = this.element.attr('id');
    if (rowId == null || rowId === '') {
      return $();
    }

    return this.element.find('.dynamic-list-delete').filter((_, el) => $(el).attr('data-dynamic-target-id') !== rowId);
  }

  private setNestedDeleteButtonsDisabled(disabled: boolean) {
    this.nestedDynamicListDeleteButtons().prop('disabled', disabled);
  }

  /** Server-rendered rows may already have _destroy set (e.g. after validation). */
  private syncNestedDeleteButtonsIfMarkedOnLoad() {
    const destroyVal = this.element.find('input.destroy').first().val();
    if (destroyVal === '1' || destroyVal === 1) {
      this.setNestedDeleteButtonsDisabled(true);
    }
  }

  deleteEvent(eventName: string) {
    if (!this.deleteHook) {
      return;
    }

    this.deleteHook(eventName);
  }

  initializeDeleteButton() {
    const $deleteButton = this.resolveOwnDeleteButton();

    if ($deleteButton.length === 0) {
      return;
    }

    $deleteButton.on('click', () => {
      if (!this.element.data('persisted')) {
        this.element.remove();
        this.deleteEvent('deleted');
      } else {
        const wasMarkedForRemoval = Boolean(this.element.data('remove'));
        const nowMarkedForRemoval = !wasMarkedForRemoval;
        this.element.data('remove', nowMarkedForRemoval);
        // Boolean `disabled` must use .prop — `attr('disabled', 'false')` leaves the attribute present and inputs stay disabled.
        this.element.find('input[type!="hidden"]').prop('disabled', nowMarkedForRemoval);
        this.element.find('input.destroy').val(nowMarkedForRemoval ? 1 : 0);
        this.setNestedDeleteButtonsDisabled(nowMarkedForRemoval);

        if (wasMarkedForRemoval) {
          this.element.find('input').removeClass('text-decoration-line-through');
          $deleteButton.removeClass('btn-primary');
          $deleteButton.addClass('btn-danger');
          $deleteButton.html('X');
          this.deleteEvent('undeleted');
        } else {
          this.element.find('input').addClass('text-decoration-line-through');
          $deleteButton.removeClass('btn-danger');
          $deleteButton.addClass('btn-primary');
          $deleteButton.html('+');
          this.deleteEvent('markedForDeletion');
        }
      }
    });
  }
}

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