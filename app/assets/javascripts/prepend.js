$(function() {
  function bindDynamicListDeleteHook() {
    // avoid problems from binding a copy of this callback multiple times
    $('.dynamic-list-delete').off('click');
    $('.dynamic-list-delete').on('click', (e) => {
      const $target = $(e.target);

      function setToRestoreButton(target) {
        target.removeClass('btn-danger');
        target.addClass('btn-primary');
        target.html('+');
      }

      function setToDeleteButton(target) {
        target.removeClass('btn-primary');
        target.addClass('btn-danger');
        target.html('X');
      }

      const $targetRow = $(`#${$target.data('dynamic-target-id')}`);
      if (!$targetRow.data('persisted')) {
        $targetRow.remove();
      } else {
        if ($targetRow.data('remove') === 'true') {
          $targetRow.data('remove', false);
          $targetRow.find('input[type!="hidden"]').attr('disabled', false);
          $targetRow.find('input.destroy').val(0);
          $targetRow.find('input').removeClass('text-decoration-line-through');
          setToDeleteButton($target);
        } else {
          $targetRow.find('input[type!="hidden"]').attr('disabled', true);
          $targetRow.data('remove', 'true');
          $targetRow.find('input.destroy').val(1);
          $targetRow.find('input').addClass('text-decoration-line-through');
          setToRestoreButton($target);
        }
      }
    });
  }

  bindDynamicListDeleteHook();
  $('[data-form-prepend]').on('click', function(e) {
    const obj = $($(this).attr('data-form-prepend'));
    const timestamp = (new Date()).getTime();
    obj.find('input,input[type="hidden"],select,textarea').each(function(_, element) {
      $(element).attr('name', function() {
        return $(element).attr('name').replace('new_record', timestamp);
      });
    });
    // dynamic timestamp selector fill-in
    if (obj.attr('id').includes("_timestamp_")) {
      obj.attr('id', obj.attr('id').replace("_timestamp_", timestamp));
    }
    obj.find("*").each((_, element) => {
      const $element = $(element);
      const targetId = $element.data('dynamic-target-id');
      if (targetId && targetId.includes("_timestamp_")) {
        console.log(targetId);
        console.log(targetId.replace("_timestamp_", timestamp));
        $element.data('dynamic-target-id', targetId.replace("_timestamp_", timestamp));
      }
    });
    $($(this).attr('data-target')).append(obj);
    bindDynamicListDeleteHook();
  });
});
