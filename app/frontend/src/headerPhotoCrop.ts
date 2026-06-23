export function headerPhotoCropScale(containerWidth: number, imageWidth: number): number {
  return imageWidth === 0 ? 0 : containerWidth / imageWidth;
}

export function headerPhotoCropObjectPosition(
  cropYOffset: number,
  containerWidth: number,
  imageWidth: number,
): string {
  const scale = headerPhotoCropScale(containerWidth, imageWidth);
  return `0px ${-cropYOffset * scale}px`;
}

export function applyHeaderPhotoCrop(
  image: HTMLImageElement,
  cropYOffset: number,
  containerWidth: number,
): void {
  if (!image.naturalWidth) {
    return;
  }

  image.style.objectPosition = headerPhotoCropObjectPosition(
    cropYOffset,
    containerWidth,
    image.naturalWidth,
  );
}

export function initPendingHeaderPhotoCrops(root: ParentNode = document): void {
  root.querySelectorAll<HTMLImageElement>('img.hero-photo--pending').forEach((image) => {
    if (image.dataset.cropInitialized === 'true') {
      return;
    }
    image.dataset.cropInitialized = 'true';

    const cropYOffset = Number(image.dataset.cropYOffset ?? 0);
    const container = image.closest('.hero-image');
    if (!container) {
      return;
    }

    const update = () => {
      applyHeaderPhotoCrop(image, cropYOffset, container.clientWidth);
    };

    if (image.complete && image.naturalWidth) {
      update();
    } else {
      image.addEventListener('load', update, { once: true });
    }

    window.addEventListener('resize', update);
  });
}
