library angular2_material.src.components.button.button;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, onChange;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/facade/lang.dart" show isPresent;

@Component(selector: "[md-button]:not([href])")
@View(templateUrl: "angular2_material/src/components/button/button.html")
class MdButton {}
@Component(
    selector: "[md-button][href]",
    properties: const {"disabled": "disabled"},
    hostListeners: const {"click": "onClick(\$event)"},
    hostProperties: const {"tabIndex": "tabIndex"},
    lifecycle: const [onChange])
@View(templateUrl: "angular2_material/src/components/button/button.html")
class MdAnchor {
  num tabIndex; /** Whether the component is disabled. */
  bool disabled;
  onClick(event) {
    // A disabled anchor shouldn't navigate anywhere.
    if (isPresent(this.disabled) && !identical(this.disabled, false)) {
      event.preventDefault();
    }
  } /** Invoked when a change is detected. */
  onChange(_) {
    // A disabled anchor should not be in the tab flow.
    this.tabIndex = this.disabled ? -1 : 0;
  }
}
