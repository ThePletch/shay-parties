import type { ControllerConstructor } from '@hotwired/stimulus';

import DynamicListController from './dynamic-list-controller.js';
import DynamicListRecordController from './dynamic-list-record-controller.js';

export const controllers: Record<string, ControllerConstructor> = {
  'dynamic-list': DynamicListController,
  'dynamic-list-record': DynamicListRecordController,
};
