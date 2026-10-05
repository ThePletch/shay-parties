import type { ControllerConstructor } from '@hotwired/stimulus';

import ConfirmController from './confirm-controller.js';
import CopyTextController from './copy-text-controller.js';
import DynamicListController from './dynamic-list-controller.js';
import DynamicListRecordController from './dynamic-list-record-controller.js';

export const controllers: Record<string, ControllerConstructor> = {
  confirm: ConfirmController,
  'copy-text': CopyTextController,
  'dynamic-list': DynamicListController,
  'dynamic-list-record': DynamicListRecordController,
};
