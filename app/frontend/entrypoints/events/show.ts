import '@/comments.js';
import { initPendingHeaderPhotoCrops } from '@/header-photo-crop.js';
import { initPlusOnes } from '@/plus-ones.js';
import { initRsvpChoice } from '@/rsvp-choice.js';

function initShowPage() {
  initPendingHeaderPhotoCrops();
  initRsvpChoice();
  initPlusOnes();
}

window.addEventListener('load', initShowPage);
window.addEventListener('turbo:render', initShowPage);