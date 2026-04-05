import $ from 'jquery';
import flatpickr from "flatpickr";

import '@/cropping.js';

import { disableFieldWith } from '@/form.js';
import { withFetchProgressIndicator } from '@/remote-calls.js'

const addressAttributeToFormFieldMap = {
  street: "#event_address_attributes_street",
  street2: "#event_address_attributes_street2",
  city: "#event_address_attributes_city",
  state: "#event_address_attributes_state",
  zip_code: "#event_address_attributes_zip_code"
};
type AddressAttribute = keyof typeof addressAttributeToFormFieldMap;

function forEachAddressAttribute(callback: (key: AddressAttribute) => void) {
  (Object.keys(addressAttributeToFormFieldMap) as (AddressAttribute)[]).forEach(callback);
}

async function updateAddressProperties(addressId: string) {
  return withFetchProgressIndicator(async function () {
    const response: Record<AddressAttribute, string> = await $.get({
      url: `/addresses/${addressId}/`,
      headers: {
        Accept: 'application/json',
      },
    });

    forEachAddressAttribute((key) => {
      const correspondingField = $(addressAttributeToFormFieldMap[key]);
      correspondingField.val(response[key]);
      correspondingField.prop('disabled', true);
    });
  });
}

function clearAddressProperties() {
  $("#fetch-error").hide();

  forEachAddressAttribute((key) => {
    const correspondingField = $(addressAttributeToFormFieldMap[key]);
    correspondingField.prop('disabled', false);
  });
}

function handleAddressChange() {
  const selectedId = $("#event_address_id").val()?.toString() ?? "";
  if (selectedId === "") {
    clearAddressProperties();
  } else {
    void updateAddressProperties(selectedId);
  }
}

$(function() {
  flatpickr(
    '.datetimepicker',
    {
      enableTime: true,
      altInput: true,
      altFormat: "m/d/Y h:i K",
      dateFormat: 'Z',
      allowInput: true,
      allowInvalidPreload: false,
    }
  );

  if ($("#event_address_id").length > 0) {
    $("#event_address_id").on('change', handleAddressChange);
    handleAddressChange();
  }
  disableFieldWith('event_plus_one_max', 'event_plus_one_enable');
});
