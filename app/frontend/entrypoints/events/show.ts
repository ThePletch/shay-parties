import '@/comments.js';
import { initPendingHeaderPhotoCrops } from '@/headerPhotoCrop.js';

function initShowPage() {
  initPendingHeaderPhotoCrops();
}

window.addEventListener('load', initShowPage);
window.addEventListener('turbo:render', initShowPage);