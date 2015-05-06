library angular2.src.change_detection.pipes.null_pipe;

import "package:angular2/src/facade/lang.dart" show isBlank, CONST;
import "pipe.dart"
    show Pipe, WrappedValue, PipeFactory; /**
 * @exportedAs angular2/pipes
 */

class NullPipeFactory extends PipeFactory {
  @CONST() const NullPipeFactory() : super();
  bool supports(obj) {
    return NullPipe.supportsObj(obj);
  }
  Pipe create(cdRef) {
    return new NullPipe();
  }
} /**
 * @exportedAs angular2/pipes
 */
class NullPipe extends Pipe {
  bool called;
  NullPipe() : super() {
    /* super call moved to initializer */;
    this.called = false;
  }
  static bool supportsObj(obj) {
    return isBlank(obj);
  }
  supports(obj) {
    return NullPipe.supportsObj(obj);
  }
  transform(value) {
    if (!this.called) {
      this.called = true;
      return WrappedValue.wrap(null);
    } else {
      return null;
    }
  }
}
