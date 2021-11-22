//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/slider
//= require jquery-ui-timepicker-addon
//= require activestorage

// resizes uploaded image to 600px across
// TODO: handle extremely tall images
const BASELINE_RESIZE_VARIANT = "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9MY21WemFYcGxhUUpZQWc9PSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--96119c68b0d6e88ff9d3408ff8e41c39036d3229"

function clamp(min, n, max) {
    if (n > max) {
        return max;
    }
    if (n < min) {
        return min;
    }
    return n;
}
var CropManager = /** @class */ (function () {
    function CropManager(interfaceSelector, imageDisplaySelector) {
        this.interfaceSelector = interfaceSelector;
        this.imageDisplaySelector = imageDisplaySelector;
        this.boundToPage = false;
        this.cropOffsetY = 0;
        this.currentDragOperation = null;
        // TODO this definitely isn't right
        this.croppingWindowHeight = $(this.interfaceSelector).height();
        this.imageHeight = $(this.imageDisplaySelector).height();
        console.log($(this.imageDisplaySelector).height());
        this.maxOffset = -(this.imageHeight - this.croppingWindowHeight);
    }


    /**
     * Bind events to page to handle and adjust state.
     */
    CropManager.prototype.bindToPage = function () {
        // block double binds
        if (this.boundToPage) {
            console.warn("Attempted to bind crop manager to page twice. Ignoring attempts after first.");
            return;
        }
        // todo guard against unmatched selectors
        $(this.interfaceSelector).on('mousedown', this.recordMousedownBeginProperties.bind(this));
        $(window).on('mouseup', this.recordMousedownEnd.bind(this));
        $(window).on('mousemove', this.updateDragOperation.bind(this));
        $(this.imageDisplaySelector).on('change', function () {
          console.log($(this.imageDisplaySelector).height());
            this.imageHeight = $(this.imageDisplaySelector).height();
          this.maxOffset = -(this.imageHeight - this.croppingWindowHeight);
        }.bind(this));
        this.boundToPage = true;
    };
    /**
     *  CALLBACKS
     */
    // mark where mousedown was first pressed to detect amount of dragging
    CropManager.prototype.recordMousedownBeginProperties = function (event) {
        this.currentDragOperation = {
            start: event.originalEvent.y,
            current: event.originalEvent.y
        };
    };
    CropManager.prototype.recordMousedownEnd = function (event) {
        this.updateDragOperation(event);
        this.cropOffsetY += this.currentDragOffset();
        this.currentDragOperation = null;
    };
    // update current crop offset on image drag
    CropManager.prototype.updateDragOperation = function (event) {
        if (this.currentDragOperation) {
            this.currentDragOperation.current = event.originalEvent.y;
        }
        // update appearance of image on screen
        $(this.imageDisplaySelector).attr({
            y: this.currentTotalOffset()
        });
    };
    /**
     *  DERIVED PROPERTIES
     */
    CropManager.prototype.currentTotalOffset = function () {
        return clamp(this.maxOffset, this.cropOffsetY + this.currentDragOffset(), 0);
    };
    CropManager.prototype.currentDragOffset = function () {
        if (this.currentDragOperation) {
            return this.currentDragOperation.current - this.currentDragOperation.start;
        }
        return 0;
    };
    return CropManager;
}());



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
  // let floob = false;
  // let floobY = -1;
  // let imgY = 0;

  const cropper = new CropManager('#image-handler', '#header-image');
  cropper.bindToPage();

  // $("#image-handler").on('mousedown', function (e) {
  //   floob = true;
  //   floobY = e.originalEvent.y;
  // });

  // $("#image-handler").on('mouseup', function (e) {
  //   floob = false;
  //   imgY = e.originalEvent.y - floobY;
  // });

  // $("#image-handler").on('mousemove', function (e) {
  //   if (floob) {
  //     $("#header-image").attr({
  //       y: imgY + e.originalEvent.y - floobY,
  //     });
  //   }
  // });

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
