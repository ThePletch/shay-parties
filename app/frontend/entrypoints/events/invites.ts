import { initializeDynamicListManagersWithin } from "@/DynamicListManager.js";

function previewUrl(form: HTMLFormElement): string | undefined {
  return form.dataset.previewUrl;
}

async function refreshInvitePreview() {
  const form = document.getElementById("invite-form") as HTMLFormElement | null;
  const preview = document.getElementById("invite-preview");
  if (form == null || preview == null) {
    return;
  }

  const url = previewUrl(form);
  if (url == null || url === "") {
    return;
  }

  const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
  const response = await fetch(url, {
    method: "POST",
    body: new FormData(form),
    headers: {
      Accept: "text/html",
      "X-CSRF-Token": token ?? "",
    },
  });
  preview.innerHTML = await response.text();
}

function debounce(fn: () => void, wait: number) {
  let timer: number | undefined;
  return () => {
    window.clearTimeout(timer);
    timer = window.setTimeout(fn, wait);
  };
}

function initInviteComposer() {
  const form = document.getElementById("invite-form");
  if (form == null) {
    return;
  }

  initializeDynamicListManagersWithin(document);
  const debouncedPreview = debounce(() => { void refreshInvitePreview(); }, 400);
  form.addEventListener("input", debouncedPreview);
  document.getElementById("invite-preview-button")?.addEventListener("click", () => {
    void refreshInvitePreview();
  });
}

window.addEventListener("load", initInviteComposer);
window.addEventListener("turbo:render", initInviteComposer);
