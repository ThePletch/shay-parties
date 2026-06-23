import { describe, it, expect } from 'vitest';
import {
  headerPhotoCropObjectPosition,
  headerPhotoCropScale,
} from './headerPhotoCrop.js';

describe('headerPhotoCropObjectPosition', () => {
  it('keeps the top of the image visible when the crop offset is zero', () => {
    expect(headerPhotoCropObjectPosition(0, 1900, 4000)).toBe('0px 0px');
  });

  it('shifts the image up to reveal lower slices of the photo', () => {
    const scale = headerPhotoCropScale(1900, 4000);
    expect(headerPhotoCropObjectPosition(1947, 1900, 4000)).toBe(`0px ${-1947 * scale}px`);
  });
});
