//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/slider
//= require jquery-ui-timepicker-addon

$(function() {
  $('.datetimepicker').datetimepicker({
    timeText: '',
    timeFormat: 'h:mm tt',
    minuteGrid: 15,
  });
});
