import $ from 'jquery';

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