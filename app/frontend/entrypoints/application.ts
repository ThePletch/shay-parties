import * as bootstrap from "bootstrap";
import '@/controllers/index.js';
import '@/tooltips.js';

type WindowWithBootstrap = typeof window & {
    bootstrap: typeof bootstrap;
};
(window as WindowWithBootstrap).bootstrap = bootstrap;

function initPopovers() {
  // initialize popovers
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach((popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl));
}

window.addEventListener('load', initPopovers);
window.addEventListener('turbo:render', initPopovers);