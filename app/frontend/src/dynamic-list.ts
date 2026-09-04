const TIMESTAMP_PLACEHOLDER = '_timestamp_';

/** Attach a shadow root from a leftover `<template shadowrootmode>` (cloneNode does not run the HTML parser). */
export function attachDeclarativeShadowRoot(host: Element): ShadowRoot | null {
  if (host.shadowRoot != null) {
    return host.shadowRoot;
  }

  const declarative = [...host.children].find((el): el is HTMLTemplateElement => (
    el instanceof HTMLTemplateElement && el.hasAttribute('shadowrootmode')
  ));
  if (declarative == null) {
    return null;
  }

  const shadow = host.attachShadow({
    mode: declarative.getAttribute('shadowrootmode') === 'closed' ? 'closed' : 'open',
    clonable: true,
  });
  shadow.append(declarative.content);
  declarative.remove();
  return shadow;
}

function visitElements(root: ParentNode, callback: (el: Element) => void): void {
  for (const el of root.querySelectorAll('*')) {
    callback(el);
    if (el instanceof HTMLTemplateElement) {
      visitElements(el.content, callback);
    }
    if (el.shadowRoot != null) {
      visitElements(el.shadowRoot, callback);
    }
  }
}

function attachDeclarativeShadowRootsWithin(root: ParentNode): void {
  visitElements(root, (el) => {
    attachDeclarativeShadowRoot(el);
  });
}

function replacePlaceholdersInValue(value: string, childIndexPlaceholder: string, uniqueId: string): string {
  return value
    .replaceAll(childIndexPlaceholder, uniqueId)
    .replaceAll(TIMESTAMP_PLACEHOLDER, uniqueId);
}

function replacePlaceholdersInTree(root: ParentNode, childIndexPlaceholder: string, uniqueId: string): void {
  visitElements(root, (el) => {
    for (const attr of [...el.attributes]) {
      if (attr.value.includes(childIndexPlaceholder) || attr.value.includes(TIMESTAMP_PLACEHOLDER)) {
        el.setAttribute(attr.name, replacePlaceholdersInValue(attr.value, childIndexPlaceholder, uniqueId));
      }
    }
  });
}

export function stampRowFromTemplate(template: HTMLTemplateElement, childIndexPlaceholder: string): DocumentFragment {
  const uniqueId = crypto.randomUUID();
  const fragment = template.content.cloneNode(true) as DocumentFragment;
  attachDeclarativeShadowRootsWithin(fragment);
  replacePlaceholdersInTree(fragment, childIndexPlaceholder, uniqueId);
  return fragment;
}
