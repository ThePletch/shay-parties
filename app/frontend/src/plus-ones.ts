export function initPlusOnes(root: ParentNode = document): void {
  root.querySelectorAll<HTMLElement>('.rsvp-plus-ones').forEach((section) => {
    if (section.dataset.plusOnesReady === 'true') {
      return;
    }
    section.dataset.plusOnesReady = 'true';

    section.querySelector<HTMLButtonElement>('[data-plus-ones-edit]')?.addEventListener('click', () => {
      section.dataset.plusOnesMode = 'form';
    });

    section.querySelector<HTMLButtonElement>('[data-plus-ones-cancel]')?.addEventListener('click', () => {
      cancelPlusOnes(section);
    });
  });
}

function cancelPlusOnes(section: HTMLElement): void {
  const rows = section.querySelector<HTMLElement>('[data-dynamic-list-target="rows"]');
  rows?.querySelectorAll<HTMLElement>(':scope > [data-controller~="dynamic-list-record"]').forEach(resetPlusOneRow);
  const saved = section.querySelector('[data-plus-one-summary]') != null;
  section.dataset.plusOnesMode = saved ? 'summary' : 'form';
  rows?.dispatchEvent(new CustomEvent('dynamic-list-record:changed', { bubbles: true }));
}

function resetPlusOneRow(row: HTMLElement): void {
  const destroy = row.querySelector<HTMLInputElement>('[data-dynamic-list-record-target="destroy"]');
  if (!destroy) {
    row.remove();
    return;
  }

  destroy.value = '0';
  row.removeAttribute('data-remove');
  row.querySelectorAll<HTMLInputElement | HTMLTextAreaElement>('input, textarea').forEach((field) => {
    if (field instanceof HTMLInputElement && field.type === 'hidden') {
      return;
    }
    field.value = field.defaultValue;
  });
}
