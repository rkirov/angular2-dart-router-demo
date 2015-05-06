library benchpress.src.validator.size_validator;

import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map;
import "package:angular2/di.dart" show bind, OpaqueToken;
import "../validator.dart" show Validator;
import "../measure_values.dart"
    show
        MeasureValues; /**
 * A validator that waits for the sample to have a certain size.
 */

class SizeValidator extends Validator {
  // TODO(tbosch): use static values when our transpiler supports them
  static get BINDINGS {
    return _BINDINGS;
  } // TODO(tbosch): use static values when our transpiler supports them
  static get SAMPLE_SIZE {
    return _SAMPLE_SIZE;
  }
  num _sampleSize;
  SizeValidator(size) : super() {
    /* super call moved to initializer */;
    this._sampleSize = size;
  }
  Map describe() {
    return {"sampleSize": this._sampleSize};
  }
  List<MeasureValues> validate(List<MeasureValues> completeSample) {
    if (completeSample.length >= this._sampleSize) {
      return ListWrapper.slice(completeSample,
          completeSample.length - this._sampleSize, completeSample.length);
    } else {
      return null;
    }
  }
}
var _SAMPLE_SIZE = new OpaqueToken("SizeValidator.sampleSize");
var _BINDINGS = [
  bind(SizeValidator).toFactory(
      (size) => new SizeValidator(size), [_SAMPLE_SIZE]),
  bind(_SAMPLE_SIZE).toValue(10)
];
