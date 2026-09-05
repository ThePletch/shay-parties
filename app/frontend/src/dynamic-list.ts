function visitElements(root: ParentNode, callback: (el: Element) => void): void {
  for (const el of root.querySelectorAll('*')) {
    callback(el);
    if (el instanceof HTMLTemplateElement) {
      visitElements(el.content, callback);
    }
  }
}

function uniqueNestedAttributeIndex(): string {
  const extra = crypto.getRandomValues(new Uint32Array(1))[0];
  return `${Date.now()}${extra}`;
}

export function stampRowFromTemplate(template: HTMLTemplateElement, childIndexPlaceholder: string): DocumentFragment {
  const uniqueId = uniqueNestedAttributeIndex();
  const fragment = template.content.cloneNode(true) as DocumentFragment;
  visitElements(fragment, (el) => {
    for (const attr of [...el.attributes]) {
      if (attr.value.includes(childIndexPlaceholder)) {
        el.setAttribute(attr.name, attr.value.replaceAll(childIndexPlaceholder, uniqueId));
      }
    }
  });
  return fragment;
}
