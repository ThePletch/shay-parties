import '@/comments.js';
import { initPendingHeaderPhotoCrops } from '@/header-photo-crop.js';

function initShowPage() {
  initPendingHeaderPhotoCrops();
}

window.addEventListener('load', initShowPage);
window.addEventListener('turbo:render', initShowPage);