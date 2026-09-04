import { Application } from '@hotwired/stimulus';

import DynamicListController from './dynamic-list-controller.js';
import DynamicListRecordController from './dynamic-list-record-controller.js';

const application = Application.start();
application.register('dynamic-list', DynamicListController);
application.register('dynamic-list-record', DynamicListRecordController);
