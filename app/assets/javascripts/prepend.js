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
        const currentlyMarkedForRemoval = $targetRow.data('remove') === 'true';
        $targetRow.data('remove', !currentlyMarkedForRemoval);
        $targetRow.find('input[type!="hidden"]').attr('disabled', !currentlyMarkedForRemoval);
        $targetRow.find('input.destroy').val(Number(!currentlyMarkedForRemoval));

        if (currentlyMarkedForRemoval) {
          $targetRow.find('input').removeClass('text-decoration-line-through');
          setToDeleteButton($target);
        } else {
          $targetRow.find('input').addClass('text-decoration-line-through');
          setToRestoreButton($target);
        }
      }
    });
  }

  function replacePlaceholdersWithTimestamp(element, recordPlaceholder, timestamp) {
    Object.entries({
      [recordPlaceholder]: ['name', 'id', 'for', 'data-form-prepend'],
      '_timestamp_': ['id', 'class', 'data-dynamic-target-id', 'data-target'],
    }).forEach(function([placeholder, attrs]) {
      attrs.forEach(function(attr) {
        $(element).attr(attr, function() {
          const currentAttr = $(element).attr(attr);
          if (currentAttr != null) {
            return currentAttr.replaceAll(placeholder, timestamp);
          }
        });
      });
    });
  }

  function bindDynamicListAddHook() {
    // avoid problems from binding a copy of this callback multiple times
    $('[data-form-prepend]').off('click');
    $('[data-form-prepend]').on('click', function(e) {
      const obj = $($(this).data('form-prepend'));
      const childIndexPlaceholder = $(this).data('prepend-child-index');
      const timestamp = (new Date()).getTime();
      obj.find('*').each(function(_, element) {
        replacePlaceholdersWithTimestamp(element, childIndexPlaceholder, timestamp);
      });
      replacePlaceholdersWithTimestamp(obj, childIndexPlaceholder, timestamp);
      $($(this).attr('data-target')).append(obj);
      bindDynamicListAddHook();
      bindDynamicListDeleteHook();
    });
  }

  bindDynamicListAddHook();
  bindDynamicListDeleteHook();
});
