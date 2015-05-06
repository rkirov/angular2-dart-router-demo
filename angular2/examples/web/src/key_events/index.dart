library examples.src.key_events.index;

import "package:angular2/angular2.dart" show bootstrap;
import "package:angular2/src/render/dom/events/key_events.dart"
    show
        KeyEventsPlugin; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/annotations_impl/view.dart"
    show View; // 2 imports for the Dart version:
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;

@Component(selector: "key-events-app")
@View(
    template: '''Click in the following area and press a key to display its name:<br>
  <div (keydown)="onKeyDown(\$event)" class="sample-area" tabindex="0">{{lastKey}}</div><br>
  Click in the following area and press shift.enter:<br>
  <div
    (keydown.shift.enter)="onShiftEnter(\$event)"
    (click)="resetShiftEnter()"
    class="sample-area"
    tabindex="0"
  >{{shiftEnter ? \'You pressed shift.enter!\' : \'\'}}</div>''')
class KeyEventsApp {
  String lastKey;
  bool shiftEnter;
  KeyEventsApp() {
    this.lastKey = "(none)";
    this.shiftEnter = false;
  }
  onKeyDown(event) {
    this.lastKey = KeyEventsPlugin.getEventFullKey(event);
    event.preventDefault();
  }
  onShiftEnter(event) {
    this.shiftEnter = true;
    event.preventDefault();
  }
  resetShiftEnter() {
    this.shiftEnter = false;
  }
}
main() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  bootstrap(KeyEventsApp);
}
