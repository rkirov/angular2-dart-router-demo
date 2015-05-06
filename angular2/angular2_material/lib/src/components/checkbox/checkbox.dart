library angular2_material.src.components.checkbox.checkbox;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/annotations_impl/di.dart" show Attribute;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2_material/src/core/constants.dart" show KEY_SPACE;
import "package:angular2/src/facade/browser.dart" show KeyboardEvent;
import "package:angular2/src/facade/lang.dart" show NumberWrapper;

@Component(
    selector: "md-checkbox",
    properties: const {"checked": "checked", "disabled": "disabled"},
    hostListeners: const {"keydown": "onKeydown(\$event)"},
    hostProperties: const {
  "tabindex": "tabindex",
  "role": "attr.role",
  "checked": "attr.aria-checked",
  "disabled_": "attr.aria-disabled"
})
@View(
    templateUrl: "angular2_material/src/components/checkbox/checkbox.html",
    directives: const [])
class MdCheckbox {
  /** Whether this checkbox is checked. */
  bool checked; /** Whether this checkbox is disabled. */
  bool disabled_; /** Setter for `role` attribute. */
  String role; /** Setter for tabindex */
  num tabindex;
  MdCheckbox(@Attribute("tabindex") String tabindex) {
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
    if (event.keyCode == KEY_SPACE) {
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
