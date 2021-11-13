//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/slider
//= require jquery-ui-timepicker-addon
//= require activestorage

// resizes uploaded image to 600px across
// TODO: handle extremely tall images
const BASELINE_RESIZE_VARIANT = "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9MY21WemFYcGxhUUpZQWc9PSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--96119c68b0d6e88ff9d3408ff8e41c39036d3229"

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
  let floob = false;
  let floobY = -1;
  let imgY = 0;

  $("#image-handler").on('mousedown', function (e) {
    floob = true;
    floobY = e.originalEvent.screenY;
  });

  $("#image-handler").on('mouseup', function (e) {
    floob = false;
    imgY = e.originalEvent.screenY - floobY;
  });

  $("#image-handler").on('mousemove', function (e) {
    if (floob) {
      $("#header-image").attr({
        y: imgY + e.originalEvent.screenY - floobY,
      });
    }
  });

  $("#event_photo").change(function(e) {
    const file = e.target.files[0];
    const url = e.target.dataset.directUploadUrl;
    const upload = new ActiveStorage.DirectUpload(file, url);

    upload.create((err, blob) => {
      if (err) {
        alert(err);
      } else {
        const newHiddenInput = $('<input>').attr({
          type: 'hidden',
          name: 'event[photo]',
          value: blob.signed_id,
        });
        // const variationKey = "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MY21WemFYcGxTU0lKTVRrd01BWTZCa1ZVT2hSamIyMWlhVzVsWDI5d2RHbHZibk43QnpvTVozSmhkbWwwZVVraUNrNXZjblJvQmpzR1ZEb0pZM0p2Y0VraUVURTVNREI0TlRBd0t6QXJNQVk3QmxRPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--19e11ecd8a5c3296b34df72596b028d54ed6c113";
        $('#header-image').attr({
          href: "/rails/active_storage/representations/" + blob.signed_id + "/" + BASELINE_RESIZE_VARIANT + "/" + blob.filename,
        });

        $(e.target).after(newHiddenInput);
      }
    });
  });

  $("#prior_addresses").change(function(e) {
    var selectedAddress = $(this).children('option:selected');
    var idField = $("#existing_address_id");

    if (selectedAddress.val() === null) {
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
