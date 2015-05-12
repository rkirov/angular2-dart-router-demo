library angular2.src.change_detection.pipes.promise_pipe;

import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/lang.dart" show isBlank, isPresent;
import "pipe.dart" show Pipe, WrappedValue;
import "../change_detector_ref.dart" show ChangeDetectorRef;
// HACK: workaround for Traceur behavior.

// It expects all transpiled modules to contain this marker.

// TODO: remove this when we no longer use traceur
var ___esModule = true;
/**
 * Implements async bindings to Promise.
 *
 * # Example
 *
 * In this example we bind the description promise to the DOM.
 * The async pipe will convert a promise to the value with which it is resolved. It will also
 * request a change detection check when the promise is resolved.
 *
 *  ```
 * @Component({
 *   selector: "task-cmp",
 *   changeDetection: ON_PUSH
 * })
 * @View({
 *  inline: "Task Description {{description|promise}}"
 * })
 * class Task {
 *  description:Promise<string>;
 * }
 *
 * ```
 *
 * @exportedAs angular2/pipes
 */
class PromisePipe extends Pipe {
  ChangeDetectorRef _ref;
  Object _latestValue;
  Object _latestReturnedValue;
  Future<dynamic> _sourcePromise;
  PromisePipe(ChangeDetectorRef ref) : super() {
    /* super call moved to initializer */;
    this._ref = ref;
    this._latestValue = null;
    this._latestReturnedValue = null;
  }
  bool supports(promise) {
    return PromiseWrapper.isPromise(promise);
  }
  void onDestroy() {}
  dynamic transform(Future<dynamic> promise) {
    if (isBlank(this._sourcePromise)) {
      this._sourcePromise = promise;
      promise.then((val) {
        if (identical(this._sourcePromise, promise)) {
          this._updateLatestValue(val);
        }
      });
      return null;
    }
    if (!identical(promise, this._sourcePromise)) {
      this._sourcePromise = null;
      return this.transform(promise);
    }
    if (identical(this._latestValue, this._latestReturnedValue)) {
      return this._latestReturnedValue;
    } else {
      this._latestReturnedValue = this._latestValue;
      return WrappedValue.wrap(this._latestValue);
    }
  }
  _updateLatestValue(Object value) {
    this._latestValue = value;
    this._ref.requestCheck();
  }
}
/**
 * Provides a factory for [PromisePipe].
 *
 * @exportedAs angular2/pipes
 */
class PromisePipeFactory {
  bool supports(promise) {
    return PromiseWrapper.isPromise(promise);
  }
  Pipe create(cdRef) {
    return new PromisePipe(cdRef);
  }
}
