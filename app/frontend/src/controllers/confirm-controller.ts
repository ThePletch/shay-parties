import { Controller } from '@hotwired/stimulus';

export default class ConfirmController extends Controller<HTMLFormElement> {
  static override values = {
    message: String,
  };

  declare readonly messageValue: string;

  guard(event: Event): void {
    if (!window.confirm(this.messageValue)) {
      event.preventDefault();
    }
  }
}
