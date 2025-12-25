import $ from 'jquery';

class CropAdjuster {
  private image: JQuery<HTMLElement>;

  private rawYOffset: number;
  private dragging: boolean;
  private imageLoaded: boolean;
  private parentDiv: JQuery<HTMLElement>;
  private parentCollapsible: JQuery<HTMLElement>
  private rawDimensions: { height: number; width: number; } | undefined;

  constructor(image: JQuery<HTMLElement>) {
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
        this.shiftYOffset(e.originalEvent?.movementY ?? 0);
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

  get parentDivHeight() {
    return this.parentDiv.height() ?? 0;
  }

  scaleToNewImage(imageUrl: string, firstLoad: boolean = false) {
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
    if (!this.rawDimensions) {
      throw new Error("Image not loaded yet");
    }

    return this.rawDimensions.height - (this.parentDivHeight / this.imageScaleFactor());
  }

  shiftYOffset(change: number) {
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
    return (this.parentDiv.width() ?? 0) / (this.rawDimensions?.width ?? 1);
  }

  scaledImageHeight() {
    return (this.rawDimensions?.height ?? 0) * this.imageScaleFactor();
  }
}

$(function () {
  $('#crop-prompt, #crop-instruction').hide();

  function setTitlePreview(newValue: string) {
    const previewObj = $('#title-preview');
    if (newValue) {
      previewObj.html(newValue);
    } else {
      previewObj.html(previewObj.data('default'));
    }
  }
  $('#event_title').on('keyup', (e) => {
    setTitlePreview($(e.target).val()?.toString() ?? '');
  });
  setTitlePreview($('#event_title').val()?.toString() ?? '');

  // handles visibility only in the crop preview
  function setTestingWarningVisible(visible: boolean) {
    $('#requires-testing').toggle(visible);
  }

  $('#event_requires_testing').on('change', (e) => {
    setTestingWarningVisible((e.target as HTMLInputElement).checked);
  });
  setTestingWarningVisible($('#event_requires_testing').prop('checked'));

  const adjuster = new CropAdjuster($("#photo-preview"));

  function loadImagePreview(input: HTMLInputElement, firstLoad = false) {
    if (input.files != null && input.files.length > 0) {
      const src = URL.createObjectURL(input.files[0]);
      adjuster.scaleToNewImage(src, firstLoad);
      $('#crop-prompt, #crop-instruction').show();
      $("#photo-preview").attr('src', src);
    } else {
      const imageSrc = $('#photo-preview').attr('src');
      if (!imageSrc) {
        throw new Error("Tried to scale to null image");
      }
      adjuster.scaleToNewImage(imageSrc, firstLoad);
      $('#crop-prompt, #crop-instruction').hide();
    }
  }

  $('input[type="file"]#event_photo').on('change', (e) => {
    loadImagePreview(e.target as HTMLInputElement, false);
  });

  const [eventPhotoInput] = $('input[type="file"]#event_photo');

  if (eventPhotoInput) {
    loadImagePreview(eventPhotoInput as HTMLInputElement, true);
  }
});
