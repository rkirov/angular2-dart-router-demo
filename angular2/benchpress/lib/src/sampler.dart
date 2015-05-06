library benchpress.src.sampler;

import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, DateTime, DateWrapper;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/collection.dart"
    show StringMapWrapper, Map, List, ListWrapper;
import "package:angular2/di.dart" show bind, OpaqueToken;
import "metric.dart" show Metric;
import "validator.dart" show Validator;
import "reporter.dart" show Reporter;
import "web_driver_adapter.dart" show WebDriverAdapter;
import "common_options.dart" show Options;
import "measure_values.dart"
    show
        MeasureValues; /**
 * The Sampler owns the sample loop:
 * 1. calls the prepare/execute callbacks,
 * 2. gets data from the metric
 * 3. asks the validator for a valid sample
 * 4. reports the new data to the reporter
 * 5. loop until there is a valid sample
 */

class Sampler {
  // TODO(tbosch): use static values when our transpiler supports them
  static get BINDINGS {
    return _BINDINGS;
  }
  WebDriverAdapter _driver;
  Metric _metric;
  Reporter _reporter;
  Validator _validator;
  Function _prepare;
  Function _execute;
  Function _now;
  Sampler({driver, metric, reporter, validator, prepare, execute, now}) {
    this._driver = driver;
    this._metric = metric;
    this._reporter = reporter;
    this._validator = validator;
    this._prepare = prepare;
    this._execute = execute;
    this._now = now;
  }
  Future<SampleState> sample() {
    var loop;
    loop = (lastState) {
      return this._iterate(lastState).then((newState) {
        if (isPresent(newState.validSample)) {
          return newState;
        } else {
          return loop(newState);
        }
      });
    };
    return loop(new SampleState([], null));
  }
  _iterate(lastState) {
    var resultPromise;
    if (isPresent(this._prepare)) {
      resultPromise = this._driver.waitFor(this._prepare);
    } else {
      resultPromise = PromiseWrapper.resolve(null);
    }
    if (isPresent(this._prepare) ||
        identical(lastState.completeSample.length, 0)) {
      resultPromise = resultPromise.then((_) => this._metric.beginMeasure());
    }
    return resultPromise
        .then((_) => this._driver.waitFor(this._execute))
        .then((_) => this._metric.endMeasure(isBlank(this._prepare)))
        .then((measureValues) => this._report(lastState, measureValues));
  }
  Future<SampleState> _report(SampleState state, Map metricValues) {
    var measureValues = new MeasureValues(
        state.completeSample.length, this._now(), metricValues);
    var completeSample =
        ListWrapper.concat(state.completeSample, [measureValues]);
    var validSample = this._validator.validate(completeSample);
    var resultPromise = this._reporter.reportMeasureValues(measureValues);
    if (isPresent(validSample)) {
      resultPromise = resultPromise.then(
          (_) => this._reporter.reportSample(completeSample, validSample));
    }
    return resultPromise
        .then((_) => new SampleState(completeSample, validSample));
  }
}
class SampleState {
  List completeSample;
  List validSample;
  SampleState(List completeSample, List validSample) {
    this.completeSample = completeSample;
    this.validSample = validSample;
  }
}
var _BINDINGS = [
  bind(Sampler).toFactory((driver, metric, reporter, validator, prepare,
      execute, now) => new Sampler(
      driver: driver,
      reporter: reporter,
      validator: validator,
      metric: metric,
      prepare: !identical(prepare, false) ? prepare : null,
      execute: execute,
      now: now), [
    WebDriverAdapter,
    Metric,
    Reporter,
    Validator,
    Options.PREPARE,
    Options.EXECUTE,
    Options.NOW
  ])
];
