library angular2_material.src.components.switcher._switch;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/annotations_impl/di.dart" show Attribute;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2_material/src/core/constants.dart" show KEY_SPACE;
import "package:angular2/src/facade/browser.dart" show KeyboardEvent;
import "package:angular2/src/facade/lang.dart"
    show
        NumberWrapper; // TODO(jelbourn): without gesture support, this is identical to MdCheckbox.

@Component(
    selector: "md-switch",
    properties: const {"checked": "checked", "disabled": "disabled"},
    hostListeners: const {"keydown": "onKeydown(\$event)"},
    hostProperties: const {
  "checked": "attr.aria-checked",
  "disabled_": "attr.aria-disabled",
  "role": "attr.role"
})
@View(
    templateUrl: "angular2_material/src/components/switcher/switch.html",
    directives: const [])
class MdSwitch {
  /** Whether this switch is checked. */
  bool checked; /** Whether this switch is disabled. */
  bool disabled_;
  num tabindex;
  String role;
  MdSwitch(@Attribute("tabindex") String tabindex) {
    this.role = "checkbox";
    this.checked = false;
    this.tabindex =
        isPresent(tabindex) ? NumberWrapper.parseInt(tabindex, 10) : 0;
  }
  get disabled {
    return this.disabled_;
  }
  set disabled(value) {
    this.disabled_ = isPresent(value) && !identical(value, false);
  }
  onKeydown(KeyboardEvent event) {
    if (identical(event.keyCode, KEY_SPACE)) {
      event.preventDefault();
      this.toggle(event);
    }
  }
  toggle(event) {
    if (this.disabled) {
      event.stopPropagation();
      return;
    }
    this.checked = !this.checked;
  }
}
