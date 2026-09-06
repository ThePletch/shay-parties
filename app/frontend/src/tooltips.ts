import * as bootstrap from 'bootstrap';

export function initTooltips(): void {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((el) => new bootstrap.Tooltip(el));
}
