//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/slider
//= require jquery-ui-timepicker-addon

const addressAttributeToFormFieldMap = {
  'street': "#event_address_attributes_street",
  'street2': "#event_address_attributes_street2",
  'city': "#event_address_attributes_city",
  'state': "#event_address_attributes_state",
  'zip_code': "#event_address_attributes_zip_code"
};

async function withFetchProgressIndicator(wrapped) {
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

async function updateAddressProperties(addressId) {
  return withFetchProgressIndicator(async function () {
    const response = await $.get({
      url: `/addresses/${addressId}/`,
      headers: {
        Accept: 'application/json',
      },
    });

    Object.keys(addressAttributeToFormFieldMap).forEach(function(key) {
      const correspondingField = $(addressAttributeToFormFieldMap[key]);
      correspondingField.val(response[key]);
      correspondingField.prop('disabled', true);
    });
  });
}

function clearAddressProperties() {
  Object.keys(addressAttributeToFormFieldMap).forEach(function(key) {
    const correspondingField = $(addressAttributeToFormFieldMap[key]);
    correspondingField.prop('disabled', false);
  });
}

function handleAddressChange() {
  const selectedId = $("#event_address_id").val();
  if (selectedId === "") {
    clearAddressProperties();
  } else {
    void updateAddressProperties(selectedId);
  }
}

$(function() {
  $('.datetimepicker').datetimepicker({
    timeText: '',
    timeFormat: 'h:mm tt',
    minuteGrid: 15,
  });

  if ($("#event_address_id").length > 0) {
    $("#event_address_id").change(handleAddressChange);
    handleAddressChange();
  }
});
