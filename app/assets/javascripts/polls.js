$(function() {
  $('[data-form-prepend]').click(function(e) {
    const obj = $($(this).attr('data-form-prepend'));
    const timestamp = (new Date()).getTime();
    obj.find('input,input[type="hidden"],select,textarea').each(function(_, element) {
      $(element).attr('name', function() {
        return $(element).attr('name').replace('new_record', timestamp);
      });
    });
    $($(this).attr('data-target')).append(obj);
  });
});
