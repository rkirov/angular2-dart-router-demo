library angular2.src.change_detection.pipes.json_pipe;

import "package:angular2/src/facade/lang.dart" show isBlank, isPresent, Json;
import "pipe.dart" show Pipe, PipeFactory;

/**
 * Implements json transforms to any object.
 *
 * # Example
 *
 * In this example we transform the user object to json.
 *
 *  ```
 * @Component({
 *   selector: "user-cmp"
 * })
 * @View({
 *   template: "User: {{ user | json }}"
 * })
 * class Username {
 *  user:Object
 *  constructor() {
 *    this.user = { name: "PatrickJS" };
 *  }
 * }
 *
 * ```
 *
 * @exportedAs angular2/pipes
 */
class JsonPipe extends Pipe {
  dynamic _latestRef;
  dynamic _latestValue;
  JsonPipe() : super() {
    /* super call moved to initializer */;
    this._latestRef = null;
    this._latestValue = null;
  }
  void onDestroy() {
    if (isPresent(this._latestValue)) {
      this._latestRef = null;
      this._latestValue = null;
    }
  }
  bool supports(obj) {
    return true;
  }
  dynamic transform(value) {
    if (identical(value, this._latestRef)) {
      return this._latestValue;
    } else {
      return this._prettyPrint(value);
    }
  }
  _prettyPrint(value) {
    this._latestRef = value;
    this._latestValue = Json.stringify(value);
    return this._latestValue;
  }
}
/**
 * Provides a factory for [JsonPipeFactory].
 *
 * @exportedAs angular2/pipes
 */
class JsonPipeFactory extends PipeFactory {
  const JsonPipeFactory() : super();
  bool supports(obj) {
    return true;
  }
  Pipe create(cdRef) {
    return new JsonPipe();
  }
}
