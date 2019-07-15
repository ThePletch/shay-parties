//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/slider
//= require jquery-ui-timepicker-addon

$(function() {
  $('.datetimepicker').datetimepicker({
    timeText: '',
    timeFormat: 'h:mm tt',
    minuteGrid: 15,
  });

  $("#prior_addresses").change(function(e) {
    var selected_address = $(this).children('option:selected');
    $("#event_address_attributes_street").val(selected_address.attr('street'));
    $("#event_address_attributes_street2").val(selected_address.attr('street2'));
    $("#event_address_attributes_city").val(selected_address.attr('city'));
    $("#event_address_attributes_state").val(selected_address.attr('state'));
    $("#event_address_attributes_zip_code").val(selected_address.attr('zip_code'));
  });
});
