library benchpress.src.reporter.multi_reporter;

import "package:angular2/di.dart" show bind, Injector, OpaqueToken;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "../measure_values.dart" show MeasureValues;
import "../reporter.dart" show Reporter;

class MultiReporter extends Reporter {
  static createBindings(childTokens) {
    return [
      bind(_CHILDREN)
          .toAsyncFactory((injector) => PromiseWrapper.all(ListWrapper.map(
              childTokens, (token) => injector.asyncGet(token))), [
        Injector
      ]),
      bind(MultiReporter)
          .toFactory((children) => new MultiReporter(children), [
        _CHILDREN
      ])
    ];
  }
  List _reporters;
  MultiReporter(reporters) : super() {
    /* super call moved to initializer */;
    this._reporters = reporters;
  }
  Future reportMeasureValues(MeasureValues values) {
    return PromiseWrapper.all(ListWrapper.map(
        this._reporters, (reporter) => reporter.reportMeasureValues(values)));
  }
  Future reportSample(
      List<MeasureValues> completeSample, List<MeasureValues> validSample) {
    return PromiseWrapper.all(ListWrapper.map(this._reporters,
        (reporter) => reporter.reportSample(completeSample, validSample)));
  }
}
var _CHILDREN = new OpaqueToken("MultiReporter.children");
