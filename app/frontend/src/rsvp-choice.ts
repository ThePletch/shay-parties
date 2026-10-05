const SUBMIT_LABEL_KEY: Record<string, string> = {
  Yes: 'labelYes',
  Maybe: 'labelMaybe',
  No: 'labelNo',
};

export function initRsvpChoice(root: ParentNode = document): void {
  root.querySelectorAll<HTMLFormElement>('form[data-rsvp-choice]').forEach((form) => {
    if (form.dataset.rsvpChoiceReady === 'true') {
      return;
    }
    form.dataset.rsvpChoiceReady = 'true';

    const reveal = form.querySelector<HTMLElement>('[data-rsvp-identity]');
    const summary = form.querySelector<HTMLElement>('[data-rsvp-identity-summary]');
    const edit = form.querySelector<HTMLButtonElement>('[data-rsvp-edit-identity]');
    const submit = form.querySelector<HTMLButtonElement>('[data-rsvp-submit-label]');
    const radios = [...form.querySelectorAll<HTMLInputElement>('input[type="radio"][name="attendance[rsvp_status]"]')];
    const pending = reveal?.dataset.rsvpIdentity === 'pending';

    const selected = () => radios.find((radio) => radio.checked);

    const syncPendingIdentity = () => {
      const choice = selected();
      if (reveal && pending) {
        reveal.hidden = !choice;
      }
      if (submit && choice) {
        const key = SUBMIT_LABEL_KEY[choice.value];
        const label = key ? submit.dataset[key] : undefined;
        if (label) {
          submit.textContent = label;
        }
      }
    };

    radios.forEach((radio) => {
      radio.addEventListener('change', () => {
        syncPendingIdentity();
        if (form.dataset.rsvpAutosubmit === 'true') {
          form.requestSubmit();
        }
      });
    });

    edit?.addEventListener('click', () => {
      if (reveal) {
        reveal.hidden = false;
      }
      if (summary) {
        summary.hidden = true;
      }
      edit.hidden = true;
    });

    syncPendingIdentity();
  });
}
