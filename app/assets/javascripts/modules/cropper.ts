type SingleAxisCoordinateDelta = {
  start: number;
  current: number;
};

interface OriginalEvent {
  y: number;
}

interface Event {
  originalEvent: OriginalEvent;
}

function $(foo: any): any {
  return foo;
}

function clamp(min: number, n: number, max: number) {
  if (n > max) {
    return max;
  }

  if (n < min) {
    return min;
  }

  return n;
}

class CropManager {
  private cropOffsetY: number;
  private currentDragOperation?: SingleAxisCoordinateDelta;
  private boundToPage: boolean;

  private croppingWindowHeight: number;
  private imageHeight: number;
  private maxOffset: number;

  constructor(
    private interfaceSelector: string,
    private imageDisplaySelector: string,
    private imageFormFieldSelector: string,
  ) {
    this.boundToPage = false;
    this.cropOffsetY = 0;
    this.currentDragOperation = null;

    // TODO this definitely isn't right
    this.croppingWindowHeight = $(this.interfaceSelector).height();
    this.imageHeight = $(this.imageDisplaySelector).height();
    this.maxOffset = -(this.imageHeight - this.croppingWindowHeight);
  }

  /**
   * Bind events to page to handle and adjust state.
   */
  public bindToPage(): void {
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
      this.imageHeight = $(this.imageDisplaySelector).height();
    }.bind(this));

    this.boundToPage = true;
  }

  /**
   *  CALLBACKS
   */

  // mark where mousedown was first pressed to detect amount of dragging
  private recordMousedownBeginProperties(event: Event): void {
    this.currentDragOperation = {
      start: event.originalEvent.y,
      current: event.originalEvent.y,
    };
  }

  private recordMousedownEnd(event: Event): void {
    this.updateDragOperation(event);
    this.cropOffsetY += this.currentDragOffset();
    this.currentDragOperation = null;
  }

  // update current crop offset on image drag
  private updateDragOperation(event: Event): void {
    if (this.currentDragOperation) {
      this.currentDragOperation.current = event.originalEvent.y;
    }

    // update appearance of image on screen
    $(this.imageDisplaySelector).attr({
      y: this.currentTotalOffset(),
    })
  }

  /**
   *  DERIVED PROPERTIES
   */

  private currentTotalOffset(): number {
    return clamp(this.maxOffset, this.cropOffsetY + this.currentDragOffset(), 0);
  }

  private currentDragOffset(): number {
    if (this.currentDragOperation) {
      return this.currentDragOperation.current - this.currentDragOperation.start;
    }

    return 0;
  }
}
