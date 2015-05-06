library angular2.src.change_detection.pipes.pipe;

import "package:angular2/src/facade/lang.dart"
    show
        ABSTRACT,
        BaseException,
        CONST; /**
 * Indicates that the result of a {@link Pipe} transformation has changed even though the reference has not changed.
 *
 * The wrapped value will be unwrapped by change detection, and the unwrapped value will be stored.
 *
 * @exportedAs angular2/pipes
 */

class WrappedValue {
  dynamic wrapped;
  WrappedValue(dynamic wrapped) {
    this.wrapped = wrapped;
  }
  static WrappedValue wrap(dynamic value) {
    var w = _wrappedValues[_wrappedIndex++ % 5];
    w.wrapped = value;
    return w;
  }
}
var _wrappedValues = [
  new WrappedValue(null),
  new WrappedValue(null),
  new WrappedValue(null),
  new WrappedValue(null),
  new WrappedValue(null)
];
var _wrappedIndex =
    0; /**
 * An interface for extending the list of pipes known to Angular.
 *
 * If you are writing a custom {@link Pipe}, you must extend this interface.
 *
 * #Example
 *
 * ```
 * class DoublePipe extends Pipe {
 *  supports(obj) {
 *    return true;
 *  }
 *
 *  transform(value) {
 *    return `${value}${value}`;
 *  }
 * }
 * ```
 *
 * @exportedAs angular2/pipes
 */
class Pipe {
  bool supports(obj) {
    return false;
  }
  onDestroy() {}
  dynamic transform(dynamic value) {
    return null;
  }
}
@ABSTRACT()
abstract class PipeFactory {
  @CONST() const PipeFactory();
  bool supports(obs) {
    return _abstract();
  }
  Pipe create(cdRef) {
    return _abstract();
  }
}
_abstract() {
  return new BaseException("This method is abstract");
}
