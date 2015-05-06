library angular2_material.src.components.progress_linear.progress_linear;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, onChange;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/annotations_impl/di.dart" show Attribute;
import "package:angular2/src/facade/lang.dart" show isPresent, isBlank;
import "package:angular2/src/facade/math.dart" show Math;

@Component(
    selector: "md-progress-linear",
    lifecycle: const [onChange],
    properties: const {"value": "value", "bufferValue": "buffer-value"},
    hostProperties: const {
  "role": "attr.role",
  "ariaValuemin": "attr.aria-valuemin",
  "ariaValuemax": "attr.aria-valuemax",
  "value": "attr.aria-valuenow"
})
@View(
    templateUrl: "angular2_material/src/components/progress-linear/progress_linear.html",
    directives: const [])
class MdProgressLinear {
  /** Value for the primary bar. */
  num value_; /** Value for the secondary bar. */
  num bufferValue; /** The render mode for the progress bar. */
  String mode; /** CSS `transform` property applied to the primary bar. */
  String primaryBarTransform; /** CSS `transform` property applied to the secondary bar. */
  String secondaryBarTransform;
  String role;
  String ariaValuemin;
  String ariaValuemax;
  MdProgressLinear(@Attribute("md-mode") String mode) {
    this.primaryBarTransform = "";
    this.secondaryBarTransform = "";
    this.role = "progressbar";
    this.ariaValuemin = "0";
    this.ariaValuemax = "100";
    this.mode = isPresent(mode) ? mode : Mode.DETERMINATE;
  }
  get value {
    return this.value_;
  }
  set value(v) {
    if (isPresent(v)) {
      this.value_ = MdProgressLinear.clamp(v);
    }
  }
  onChange(_) {
    // If the mode does not use a value, or if there is no value, do nothing.
    if (this.mode == Mode["QUERY"] ||
        this.mode == Mode["INDETERMINATE"] ||
        isBlank(this.value)) {
      return;
    }
    this.primaryBarTransform = this.transformForValue(
        this.value); // The bufferValue is only used in buffer mode.
    if (this.mode == Mode["BUFFER"]) {
      this.secondaryBarTransform = this.transformForValue(this.bufferValue);
    }
  } /** Gets the CSS `transform` property for a progress bar based on the given value (0 - 100). */
  transformForValue(value) {
    // TODO(jelbourn): test perf gain of caching these, since there are only 101 values.
    var scale = value / 100;
    var translateX = (value - 100) / 2;
    return '''translateX(${ translateX}%) scale(${ scale}, 1)''';
  } /** Clamps a value to be between 0 and 100. */
  static clamp(v) {
    return Math.max(0, Math.min(100, v));
  }
} /** @enum {string} Progress-linear modes. */
var Mode = {
  "DETERMINATE": "determinate",
  "INDETERMINATE": "indeterminate",
  "BUFFER": "buffer",
  "QUERY": "query"
};
