library angular2.src.change_detection.pipes.lowercase_pipe;

import "package:angular2/src/facade/lang.dart" show isString, StringWrapper;
import "pipe.dart" show Pipe;

/**
 * Implements lowercase transforms to text.
 *
 * # Example
 *
 * In this example we transform the user text lowercase.
 *
 *  ```
 * @Component({
 *   selector: "username-cmp"
 * })
 * @View({
 *   template: "Username: {{ user | lowercase }}"
 * })
 * class Username {
 *   user:string;
 * }
 *
 * ```
 *
 * @exportedAs angular2/pipes
 */
class LowerCasePipe extends Pipe {
  String _latestValue;
  LowerCasePipe() : super() {
    /* super call moved to initializer */;
    this._latestValue = null;
  }
  bool supports(str) {
    return isString(str);
  }
  void onDestroy() {
    this._latestValue = null;
  }
  String transform(String value) {
    if (!identical(this._latestValue, value)) {
      this._latestValue = value;
      return StringWrapper.toLowerCase(value);
    } else {
      return this._latestValue;
    }
  }
}
/**
 * @exportedAs angular2/pipes
 */
class LowerCaseFactory {
  bool supports(str) {
    return isString(str);
  }
  Pipe create() {
    return new LowerCasePipe();
  }
}
