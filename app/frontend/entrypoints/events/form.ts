import $ from 'jquery';
import flatpickr from "flatpickr";

import { refreshHeaderPhotoCrop } from '@/cropping.js';

import { configureDirectUpload } from '@/form.js';
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
  (Object.keys(addressAttributeToFormFieldMap) as AddressAttribute[]).forEach(callback);
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
    renderLocationSummary();
  });
}

function addressFieldValue(selector: string) {
  return $(selector).val()?.toString().trim() ?? "";
}

function locationSummaryText() {
  const street = addressFieldValue(addressAttributeToFormFieldMap.street);
  const unit = addressFieldValue(addressAttributeToFormFieldMap.street2);
  const city = addressFieldValue(addressAttributeToFormFieldMap.city);
  const state = addressFieldValue(addressAttributeToFormFieldMap.state);
  const zipCode = addressFieldValue(addressAttributeToFormFieldMap.zip_code);
  const firstLine = [street, unit].filter((part) => part.length > 0).join(", ");
  const cityState = [city, state].filter((part) => part.length > 0).join(", ");
  const secondLine = [cityState, zipCode].filter((part) => part.length > 0).join(" ");
  return [firstLine, secondLine].filter((part) => part.length > 0).join(", ");
}

function renderLocationSummary() {
  const line = locationSummaryText();
  const filled = line.length > 0;
  $("#event-location-line").text(line);
  $("#event-location-filled").prop("hidden", !filled);
  $("#event-location-add").prop("hidden", filled);
}

function showLocationEditor() {
  $("#event-location-summary").prop("hidden", true);
  $("#event-location-editor").prop("hidden", false);
}

function hideLocationEditor() {
  renderLocationSummary();
  $("#event-location-editor").prop("hidden", true);
  $("#event-location-summary").prop("hidden", false);
}

function setCropOpen(open: boolean) {
  const button = document.getElementById("event-photo-crop-toggle");
  const crop = document.getElementById("event-photo-crop");
  if (!button || !crop) {
    return;
  }
  crop.hidden = !open;
  button.setAttribute("aria-expanded", open ? "true" : "false");
  const label = open ? button.dataset.hideLabel : button.dataset.showLabel;
  if (label) {
    button.textContent = label;
  }
  if (open) {
    refreshHeaderPhotoCrop();
  }
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
  configureDirectUpload(true);

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

  $("#event-location-add, #event-location-change").on("click", showLocationEditor);
  $("#event-location-done").on("click", hideLocationEditor);

  $("#event_requires_testing").on("change", (event) => {
    $("#event-testing-help").prop("hidden", !(event.target as HTMLInputElement).checked);
  });

  $("#event-photo-crop-toggle").on("click", () => {
    const crop = document.getElementById("event-photo-crop");
    setCropOpen(crop?.hidden ?? true);
  });

  $("#event_photo").on("change", (event) => {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) {
      return;
    }
    $("#event-photo-add").prop("hidden", true);
    $("#event-photo-chosen").prop("hidden", false);
    $("#event-photo-name").text(file.name);
    $("#event-photo-thumb").attr("src", URL.createObjectURL(file));
    setCropOpen(true);
  });
});
