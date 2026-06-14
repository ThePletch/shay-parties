import { vi } from 'vitest';

vi.mock('@rails/activestorage', () => ({
  start: vi.fn(),
}));
