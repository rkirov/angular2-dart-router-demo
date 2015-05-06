library angular2_material.src.components.radio.radio_dispatcher;

import "package:angular2/src/facade/collection.dart"
    show
        List,
        ListWrapper; /**
 * Class for radio buttons to coordinate unique selection based on name.
 * Indended to be consumed as an Angular service.
 */

class MdRadioDispatcher {
  // TODO(jelbourn): Change this to TypeScript syntax when supported.
  List<Function> listeners_;
  MdRadioDispatcher() {
    this.listeners_ = [];
  } /** Notify other nadio buttons that selection for the given name has been set. */
  notify(String name) {
    ListWrapper.forEach(this.listeners_, (f) => f(name));
  } /** Listen for future changes to radio button selection. */
  listen(listener) {
    ListWrapper.push(this.listeners_, listener);
  }
}
