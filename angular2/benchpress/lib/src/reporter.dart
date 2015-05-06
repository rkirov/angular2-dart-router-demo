library benchpress.src.reporter;

import "package:angular2/di.dart" show bind;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/lang.dart" show ABSTRACT, BaseException;
import "measure_values.dart"
    show
        MeasureValues; /**
 * A reporter reports measure values and the valid sample.
 */

@ABSTRACT()
abstract class Reporter {
  static bindTo(delegateToken) {
    return [bind(Reporter).toFactory((delegate) => delegate, [delegateToken])];
  }
  Future reportMeasureValues(MeasureValues values) {
    throw new BaseException("NYI");
  }
  Future reportSample(
      List<MeasureValues> completeSample, List<MeasureValues> validSample) {
    throw new BaseException("NYI");
  }
}
