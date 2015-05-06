library benchpress.src.runner;

import "package:angular2/di.dart" show Injector, bind;
import "package:angular2/src/facade/lang.dart" show isPresent, isBlank;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/facade/async.dart" show Future;
import "sampler.dart" show Sampler, SampleState;
import "reporter/console_reporter.dart" show ConsoleReporter;
import "reporter/multi_reporter.dart" show MultiReporter;
import "validator/regression_slope_validator.dart"
    show RegressionSlopeValidator;
import "validator/size_validator.dart" show SizeValidator;
import "validator.dart" show Validator;
import "metric/perflog_metric.dart" show PerflogMetric;
import "metric/multi_metric.dart" show MultiMetric;
import "webdriver/chrome_driver_extension.dart" show ChromeDriverExtension;
import "webdriver/ios_driver_extension.dart" show IOsDriverExtension;
import "web_driver_extension.dart" show WebDriverExtension;
import "sample_description.dart" show SampleDescription;
import "web_driver_adapter.dart" show WebDriverAdapter;
import "reporter.dart" show Reporter;
import "metric.dart" show Metric;
import "common_options.dart"
    show
        Options; /**
 * The Runner is the main entry point for executing a sample run.
 * It provides defaults, creates the injector and calls the sampler.
 */

class Runner {
  List _defaultBindings;
  Runner([List defaultBindings = null]) {
    if (isBlank(defaultBindings)) {
      defaultBindings = [];
    }
    this._defaultBindings = defaultBindings;
  }
  Future<SampleState> sample({id, execute, prepare, microMetrics, bindings}) {
    var sampleBindings = [
      _DEFAULT_BINDINGS,
      this._defaultBindings,
      bind(Options.SAMPLE_ID).toValue(id),
      bind(Options.EXECUTE).toValue(execute)
    ];
    if (isPresent(prepare)) {
      ListWrapper.push(sampleBindings, bind(Options.PREPARE).toValue(prepare));
    }
    if (isPresent(microMetrics)) {
      ListWrapper.push(
          sampleBindings, bind(Options.MICRO_METRICS).toValue(microMetrics));
    }
    if (isPresent(bindings)) {
      ListWrapper.push(sampleBindings, bindings);
    }
    return Injector
        .resolveAndCreate(sampleBindings)
        .asyncGet(Sampler)
        .then((sampler) => sampler.sample());
  }
}
var _DEFAULT_BINDINGS = [
  Options.DEFAULT_BINDINGS,
  Sampler.BINDINGS,
  ConsoleReporter.BINDINGS,
  RegressionSlopeValidator.BINDINGS,
  SizeValidator.BINDINGS,
  ChromeDriverExtension.BINDINGS,
  IOsDriverExtension.BINDINGS,
  PerflogMetric.BINDINGS,
  SampleDescription.BINDINGS,
  MultiReporter.createBindings([ConsoleReporter]),
  MultiMetric.createBindings([PerflogMetric]),
  Reporter.bindTo(MultiReporter),
  Validator.bindTo(RegressionSlopeValidator),
  WebDriverExtension.bindTo([ChromeDriverExtension, IOsDriverExtension]),
  Metric.bindTo(MultiMetric),
  bind(Options.CAPABILITIES).toAsyncFactory(
      (adapter) => adapter.capabilities(), [WebDriverAdapter]),
  bind(Options.USER_AGENT).toAsyncFactory(
      (adapter) => adapter.executeScript("return window.navigator.userAgent;"),
      [WebDriverAdapter])
];
