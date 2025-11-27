class DynamicListRecord {
  static fromTemplate(template, childIndexPlaceholder, deleteHook) {
    const element = $(template);

    const timestamp = (new Date()).getTime();

    const replacePlaceholdersWithTimestamp = (element) => {
      const jqElement = $(element);
      Object.entries({
        [childIndexPlaceholder]: ['name', 'id', 'for', 'data-form-prepend'],
        '_timestamp_': ['id', 'class', 'data-dynamic-target-id', 'data-target'],
      }).forEach(([placeholder, attrs]) => {
        attrs.forEach((attr) => {
          jqElement.attr(attr, () => {
            const currentAttr = jqElement.attr(attr);
            if (currentAttr != null) {
              return currentAttr.replaceAll(placeholder, timestamp);
            }
          });
        });
      });
    };

    element.find('*').each((_, element) => replacePlaceholdersWithTimestamp(element));
    replacePlaceholdersWithTimestamp(element);

    return new DynamicListRecord(element, deleteHook);
  }

  constructor(element, deleteHook) {
    this.element = element;
    this.deleteHook = deleteHook;

    this.initializeDeleteButton();
  }

  deleteEvent(eventName) {
    if (!this.deleteHook) {
      return;
    }

    this.deleteHook(eventName);
  }

  initializeDeleteButton() {
    const deleteButton = this.element.find('.dynamic-list-delete');

    deleteButton.on('click', () => {
      if (!this.element.data('persisted')) {
        this.element.remove();
        this.deleteEvent('deleted');
      } else {
        const currentlyMarkedForRemoval = this.element.data('remove');
        this.element.data('remove', !currentlyMarkedForRemoval);
        this.element.find('input[type!="hidden"]').attr('disabled', !currentlyMarkedForRemoval);
        this.element.find('input.destroy').val(Number(!currentlyMarkedForRemoval));

        if (currentlyMarkedForRemoval) {
          this.element.find('input').removeClass('text-decoration-line-through');
          deleteButton.removeClass('btn-primary');
          deleteButton.addClass('btn-danger');
          deleteButton.html('X');
          this.deleteEvent('undeleted');
        } else {
          this.element.find('input').addClass('text-decoration-line-through');
          deleteButton.removeClass('btn-danger');
          deleteButton.addClass('btn-primary');
          deleteButton.html('+');
          this.deleteEvent('markedForDeletion');
        }
      }
    });
  }
}

class DynamicListManager {
  constructor(addButtonId) {
    this.addButton = $('#' + addButtonId);
    this.recordLimit = this.addButton.data('record-limit');
    this.targetElement = $(this.addButton.data('target'));

    this.prependTemplate = this.addButton.data('form-prepend');
    if (this.prependTemplate == null) {
      throw new Error(`No data-form-prepend attribute found on record add button for ID #${addButtonId}. This is necessary to add new records.`);
    }

    this.childIndexPlaceholder = this.addButton.data('prepend-child-index');
    if (this.childIndexPlaceholder == null) {
      throw new Error(`No data-prepend-child-index attribute found on record add button for ID #${addButtonId}. This is necessary to properly template new records.`);
    }

    this.addButton.on('click', () => {
      this.targetElement.append(DynamicListRecord.fromTemplate(this.prependTemplate, this.childIndexPlaceholder, this.enforceListLimit.bind(this)).element);
      this.enforceListLimit();
    });
    // initialize existing records as DynamicListRecords
    this.targetElement.children().each((_, childElement) => new DynamicListRecord($(childElement), this.enforceListLimit.bind(this)));

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

$(function() {
  $('[data-form-prepend]').each((_, button) => new DynamicListManager(button.id));
});
