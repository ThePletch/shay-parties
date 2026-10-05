import $ from 'jquery';

import { headerPhotoCropObjectPosition } from '@/header-photo-crop.js';

class CropAdjuster {
  private image: JQuery<HTMLElement>;

  private rawYOffset: number;
  private dragging: boolean;
  private imageLoaded: boolean;
  private parentDiv: JQuery<HTMLElement>;
  private rawDimensions: { height: number; width: number; } | undefined;

  constructor(image: JQuery<HTMLElement>) {
    this.image = image;
    this.rawYOffset = -this.image.data('initial-y-offset');
    this.dragging = false;
    this.imageLoaded = false;

    this.parentDiv = this.image.closest('.event-photo-frame');
    this.parentDiv.on('mousedown', (e) => {
      e.preventDefault();
      this.dragging = true;
    });
    this.parentDiv.on('mousemove', (e) => {
      if (this.dragging && this.imageLoaded) {
        this.shiftYOffset(e.originalEvent?.movementY ?? 0);
      }
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
      // The crop frame has no width while it is hidden.
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
    if (!this.rawDimensions) {
      return;
    }

    this.image.css({
      objectPosition: headerPhotoCropObjectPosition(
        -this.rawYOffset,
        this.parentDiv.width() ?? 0,
        this.rawDimensions.width,
      ),
    });
  }

  imageScaleFactor() {
    return (this.parentDiv.width() ?? 0) / (this.rawDimensions?.width ?? 1);
  }

  scaledImageHeight() {
    return (this.rawDimensions?.height ?? 0) * this.imageScaleFactor();
  }

  refresh() {
    if (!this.rawDimensions) {
      return;
    }
    this.shiftYOffset(0);
  }
}

let adjuster: CropAdjuster | undefined;

export function refreshHeaderPhotoCrop() {
  adjuster?.refresh();
}

$(function () {
  const preview = $("#photo-preview");
  if (preview.length === 0) {
    return;
  }

  adjuster = new CropAdjuster(preview);

  function loadImagePreview(input: HTMLInputElement, firstLoad = false) {
    if (!adjuster) {
      return;
    }
    if (input.files != null && input.files.length > 0) {
      const src = URL.createObjectURL(input.files[0]!);
      adjuster.scaleToNewImage(src, firstLoad);
      $("#photo-preview").attr('src', src);
    } else {
      const imageSrc = $('#photo-preview').attr('src');
      if (!imageSrc) {
        return;
      }
      adjuster.scaleToNewImage(imageSrc, firstLoad);
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
