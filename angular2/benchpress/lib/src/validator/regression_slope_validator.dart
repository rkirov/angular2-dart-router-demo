library benchpress.src.validator.regression_slope_validator;

import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map;
import "package:angular2/di.dart" show bind, OpaqueToken;
import "../validator.dart" show Validator;
import "../statistic.dart" show Statistic;
import "../measure_values.dart"
    show
        MeasureValues; /**
 * A validator that checks the regression slope of a specific metric.
 * Waits for the regression slope to be >=0.
 */

class RegressionSlopeValidator extends Validator {
  // TODO(tbosch): use static values when our transpiler supports them
  static get SAMPLE_SIZE {
    return _SAMPLE_SIZE;
  } // TODO(tbosch): use static values when our transpiler supports them
  static get METRIC {
    return _METRIC;
  } // TODO(tbosch): use static values when our transpiler supports them
  static get BINDINGS {
    return _BINDINGS;
  }
  num _sampleSize;
  String _metric;
  RegressionSlopeValidator(sampleSize, metric) : super() {
    /* super call moved to initializer */;
    this._sampleSize = sampleSize;
    this._metric = metric;
  }
  Map describe() {
    return {
      "sampleSize": this._sampleSize,
      "regressionSlopeMetric": this._metric
    };
  }
  List<MeasureValues> validate(List<MeasureValues> completeSample) {
    if (completeSample.length >= this._sampleSize) {
      var latestSample = ListWrapper.slice(completeSample,
          completeSample.length - this._sampleSize, completeSample.length);
      var xValues = [];
      var yValues = [];
      for (var i = 0; i < latestSample.length; i++) {
        // For now, we only use the array index as x value.
        // TODO(tbosch): think about whether we should use time here instead
        ListWrapper.push(xValues, i);
        ListWrapper.push(yValues, latestSample[i].values[this._metric]);
      }
      var regressionSlope = Statistic.calculateRegressionSlope(xValues,
          Statistic.calculateMean(xValues), yValues,
          Statistic.calculateMean(yValues));
      return regressionSlope >= 0 ? latestSample : null;
    } else {
      return null;
    }
  }
}
var _SAMPLE_SIZE = new OpaqueToken("RegressionSlopeValidator.sampleSize");
var _METRIC = new OpaqueToken("RegressionSlopeValidator.metric");
var _BINDINGS = [
  bind(RegressionSlopeValidator).toFactory(
      (sampleSize, metric) => new RegressionSlopeValidator(sampleSize, metric),
      [_SAMPLE_SIZE, _METRIC]),
  bind(_SAMPLE_SIZE).toValue(10),
  bind(_METRIC).toValue("scriptTime")
];
