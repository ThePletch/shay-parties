import * as bootstrap from "bootstrap";
import { Application } from '@hotwired/stimulus';
import { controllers } from '@/controllers/index.js';
import { initTooltips } from '@/tooltips.js';

type WindowWithBootstrap = typeof window & {
    bootstrap: typeof bootstrap;
};
(window as WindowWithBootstrap).bootstrap = bootstrap;

const stimulus = Application.start();
for (const [identifier, controller] of Object.entries(controllers)) {
  stimulus.register(identifier, controller);
}

function initPopovers() {
  // initialize popovers
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach((popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl));
}

window.addEventListener('load', initPopovers);
window.addEventListener('load', initTooltips);
window.addEventListener('turbo:render', initPopovers);