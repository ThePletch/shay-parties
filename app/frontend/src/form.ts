import $ from 'jquery';
import * as ActiveStorage from "@rails/activestorage";

export function disableFieldWith(fieldId: string, checkboxId: string) {
  const checkbox = $('#' + checkboxId);
  const field = $('#' + fieldId);
  function syncFieldWithCheckbox() {
    if (checkbox.is(':checked')) {
      field.prop('disabled', false);
    } else {
      field.prop('disabled', true);
    }
  }
  checkbox.on('change', syncFieldWithCheckbox);
  syncFieldWithCheckbox();
}

export function configureDirectUpload(debug: boolean) {
  ActiveStorage.start();

  if (debug) {
    [
      'initialize',
      'before-blob-request',
      'before-storage-request',
      'progress',
      'error',
      'end',
    ].forEach(event => addEventListener(`direct-upload:${event}`, console.debug));
  }
}