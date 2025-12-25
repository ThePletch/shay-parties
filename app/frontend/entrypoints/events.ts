import $ from 'jquery';
import flatpickr from "flatpickr";

import './cropping';

import { disableFieldWith } from './form';

const addressAttributeToFormFieldMap = {
  street: "#event_address_attributes_street",
  street2: "#event_address_attributes_street2",
  city: "#event_address_attributes_city",
  state: "#event_address_attributes_state",
  zip_code: "#event_address_attributes_zip_code"
};

async function withFetchProgressIndicator(wrapped: () => Promise<unknown>) {
  // don't show the spinner until half a second has passed to avoid flashing the spinner on screen.
  const fetchSpinnerTimeout = setTimeout(() => $("#fetch-in-progress").show(), 500);
  try {
    $("#fetch-error").hide();
    return await wrapped();
  } catch (e) {
    $("#fetch-error").show();
    throw e;
  } finally {
    clearTimeout(fetchSpinnerTimeout);
    $("#fetch-in-progress").hide();
  }
}

function forEachAddressAttribute(callback: (key: keyof typeof addressAttributeToFormFieldMap) => void) {
  (Object.keys(addressAttributeToFormFieldMap) as (keyof typeof addressAttributeToFormFieldMap)[]).forEach(callback);
}

async function updateAddressProperties(addressId: string) {
  return withFetchProgressIndicator(async function () {
    const response = await $.get({
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
  flatpickr('.datetimepicker', { enableTime: true, dateFormat: "m/d/Y h:i K", allowInput: true, allowInvalidPreload: true });

  if ($("#event_address_id").length > 0) {
    $("#event_address_id").change(handleAddressChange);
    handleAddressChange();
  }
  disableFieldWith('event_plus_one_max', 'event_plus_one_enable');
});
