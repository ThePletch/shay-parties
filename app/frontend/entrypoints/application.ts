import * as bootstrap from "bootstrap";
import { initializeDynamicListManagersWithin } from "@/prepend.js";
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
window.addEventListener('load', () => initializeDynamicListManagersWithin(document));
window.addEventListener('turbo:render', initPopovers);