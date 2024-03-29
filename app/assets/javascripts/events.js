//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/slider
//= require jquery-ui-timepicker-addon

$(function() {
  $('.datetimepicker').datetimepicker({
    timeText: '',
    timeFormat: 'h:mm tt',
    minuteGrid: 15,
  });

  var addressAttributeToFormFieldMap = {
    'street': "#event_address_attributes_street",
    'street2': "#event_address_attributes_street2",
    'city': "#event_address_attributes_city",
    'state': "#event_address_attributes_state",
    'zip_code': "#event_address_attributes_zip_code"
  };

  $("#prior_addresses").change(function(e) {
    var selectedAddress = $(this).children('option:selected');
    var idField = $("#existing_address_id");
    if ([null, ""].includes(selectedAddress.val())) {
      idField.val(null);

      Object.keys(addressAttributeToFormFieldMap).forEach(function(key) {
        var correspondingField = $(addressAttributeToFormFieldMap[key]);
        correspondingField.val("");
        correspondingField.prop('disabled', false);
      });
    } else {
      // use the selected address's fields
      idField.val(selectedAddress.val());

      // fill in and lock all the 'new address' fields, since we're using an existing address.
      // disabling the fields prevents them from being submitted with the form.
      Object.keys(addressAttributeToFormFieldMap).forEach(function(key) {
        var correspondingField = $(addressAttributeToFormFieldMap[key]);
        correspondingField.val(selectedAddress.attr(key));
        correspondingField.prop('disabled', true);
      });
    }
  });
});
