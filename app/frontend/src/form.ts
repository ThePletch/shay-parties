import * as ActiveStorage from "@rails/activestorage";

export function configureDirectUpload(debug: boolean) {
  ActiveStorage.start();

  if (debug) {
    [
      'initialize',
      'before-blob-request',
      'before-storage-request',
      'progress',
      'error',
      'end',
    ].forEach(event => addEventListener(`direct-upload:${event}`, console.debug));
  }
}