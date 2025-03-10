class CropAdjuster {
  constructor(image) {
    this.image = image;
    this.rawYOffset = -this.image.data('initial-y-offset');
    this.dragging = false;
    this.imageLoaded = false;

    this.parentDiv = this.image.closest('.hero-image');
    this.parentCollapsible = this.image.closest('.accordion');
    this.parentDiv.on('mousedown', (e) => {
      e.preventDefault();
      this.dragging = true;
    });
    this.parentDiv.on('mousemove', (e) => {
      if (this.dragging && this.imageLoaded) {
        this.shiftYOffset(e.originalEvent.movementY);
      }
    });
    this.parentCollapsible.on('click', () => {
      this.shiftYOffset(0);
    });
    $(window).on('mouseup', () => {
      this.dragging = false;
    });
    $(window).on('resize', () => {
      this.updateImageShift();
    });
  }

  parentDivHeight() {
    return this.parentDiv.height();
  }

  scaleToNewImage(imageUrl, firstLoad = false) {
    this.imageLoaded = false;
    const image = new Image();
    image.onload = () => {
      this.rawDimensions = {
        height: image.height,
        width: image.width,
      };
      // Don't reset the offset on page load,
      // so we show the correct offset when editing
      // the form.
      if (!firstLoad) {
        this.rawYOffset = 0;
      }
      this.shiftYOffset(0);
      this.imageLoaded = true;
    }
    image.src = imageUrl;
  }

  heightShiftRange() {
    return this.rawDimensions.height - (this.parentDiv.height() / this.imageScaleFactor());
  }

  shiftYOffset(change) {
    if (this.imageScaleFactor() === 0) {
      // image scale factor will be zero when the preview is minimized
      // abort early so we don't end up dividing by zero
      return;
    }

    this.rawYOffset = Math.min(
      Math.max(
        -this.heightShiftRange(),
        this.rawYOffset + change / this.imageScaleFactor(),
      ),
      0,
    );
    $('#event_photo_crop_y_offset').val(Math.round(-this.rawYOffset));
    this.updateImageShift();
  }

  updateImageShift() {
    this.image.css({
      'objectPosition': '0px ' + this.rawYOffset * this.imageScaleFactor() + 'px',
    });
  }

  imageScaleFactor() {
    return this.parentDiv.width() / this.rawDimensions.width;
  }

  scaledImageHeight() {
    return this.rawDimensions.height * this.imageScaleFactor();
  }
}

$(function () {
  $('#crop-prompt, #crop-instruction').hide();

  function setTitlePreview(newValue) {
    const previewObj = $('#title-preview');
    if (newValue) {
      previewObj.html(newValue);
    } else {
      previewObj.html(previewObj.data('default'));
    }
  }
  $('#event_title').on('keyup', (e) => {
    setTitlePreview($(e.target).val());
  });
  setTitlePreview($('#event_title').val());

  function setTestingWarningVisible(visible) {
    $('#requires-testing').toggle(visible);
  }

  $('#event_requires_testing').on('change', (e) => {
    setTestingWarningVisible(e.target.checked);
  });
  setTestingWarningVisible(document.getElementById('event_requires_testing').checked);

  const adjuster = new CropAdjuster($("#photo-preview"));

  function loadImagePreview(input, firstLoad = false) {
    if (input.files != null && input.files.length > 0) {
      const src = URL.createObjectURL(input.files[0]);
      adjuster.scaleToNewImage(src, firstLoad);
      $('#crop-prompt, #crop-instruction').show();
      $("#photo-preview").attr('src', src);
    } else {
      adjuster.scaleToNewImage($('#photo-preview').attr('src'), firstLoad);
      $('#crop-prompt, #crop-instruction').hide();
    }
  }

  $('input[type="file"]#event_photo').on('change', (e) => {
    loadImagePreview(e.target, false);
  });

  const [eventPhotoInput] = $('input[type="file"]#event_photo');

  if (eventPhotoInput) {
    loadImagePreview(eventPhotoInput, true);
  }
});
