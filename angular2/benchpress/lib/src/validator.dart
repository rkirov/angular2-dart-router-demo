library benchpress.src.validator;

import "package:angular2/di.dart" show bind;
import "package:angular2/src/facade/collection.dart" show List, Map;
import "package:angular2/src/facade/lang.dart" show ABSTRACT, BaseException;
import "measure_values.dart"
    show
        MeasureValues; /**
 * A Validator calculates a valid sample out of the complete sample.
 * A valid sample is a sample that represents the population that should be observed
 * in the correct way.
 */

@ABSTRACT()
abstract class Validator {
  static bindTo(delegateToken) {
    return [bind(Validator).toFactory((delegate) => delegate, [delegateToken])];
  } /**
   * Calculates a valid sample out of the complete sample
   */
  List<MeasureValues> validate(List<MeasureValues> completeSample) {
    throw new BaseException("NYI");
  } /**
   * Returns a Map that describes the properties of the validator
   * (e.g. sample size, ...)
   */
  Map describe() {
    throw new BaseException("NYI");
  }
}
