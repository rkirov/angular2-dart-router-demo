library benchpress.src.metric;

import "package:angular2/di.dart" show bind;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/lang.dart" show ABSTRACT, BaseException;
import "package:angular2/src/facade/collection.dart"
    show Map; /**
 * A metric is measures values
 */

@ABSTRACT()
abstract class Metric {
  static bindTo(delegateToken) {
    return [bind(Metric).toFactory((delegate) => delegate, [delegateToken])];
  } /**
   * Starts measuring
   */
  Future beginMeasure() {
    throw new BaseException("NYI");
  } /**
   * Ends measuring and reports the data
   * since the begin call.
   * @param restart: Whether to restart right after this.
   */
  Future<Map> endMeasure(bool restart) {
    throw new BaseException("NYI");
  } /**
   * Describes the metrics provided by this metric implementation.
   * (e.g. units, ...)
   */
  Map describe() {
    throw new BaseException("NYI");
  }
}
