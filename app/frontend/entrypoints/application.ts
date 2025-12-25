import * as bootstrap from "bootstrap";
import { initializeDynamicListManagers } from "./prepend";
import './tooltips';

type WindowWithBootstrap = typeof window & {
    bootstrap: typeof bootstrap;
};
(window as WindowWithBootstrap).bootstrap = bootstrap;

function initPage() {
  // initialize popovers
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach((popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl));
}

window.addEventListener('load', initPage);
window.addEventListener('load', initializeDynamicListManagers);
window.addEventListener('turbo:render', initPage);