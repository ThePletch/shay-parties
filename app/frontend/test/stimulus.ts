import { Application } from '@hotwired/stimulus';
import type { ControllerConstructor } from '@hotwired/stimulus';

const MAX_CONNECTION_TICKS = 100;

// Stimulus connects controllers from MutationObserver callbacks, which jsdom delivers
// as microtasks, so tests must yield while waiting for a controller to appear.
// (setTimeout would be faked out by the vitest config and hang.)
export async function waitForController(application: Application, element: Element, identifier: string): Promise<void> {
  for (let tick = 0; tick < MAX_CONNECTION_TICKS; tick++) {
    if (application.getControllerForElementAndIdentifier(element, identifier) != null) {
      return;
    }
    await Promise.resolve();
  }

  throw new Error(`Controller "${identifier}" did not connect to <${element.tagName.toLowerCase()}#${element.id}>.`);
}

export async function startStimulusWith(controllers: Record<string, ControllerConstructor>): Promise<Application> {
  const application = Application.start();
  for (const [identifier, controller] of Object.entries(controllers)) {
    application.register(identifier, controller);
  }
  await Promise.all(
    [...document.querySelectorAll('[data-controller]')].flatMap((element) =>
      (element.getAttribute('data-controller') ?? '')
        .split(' ')
        .filter((identifier) => identifier !== '')
        .map((identifier) => waitForController(application, element, identifier)),
    ),
  );
  return application;
}
