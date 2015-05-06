library benchpress.src.metric.multi_metric;

import "package:angular2/di.dart" show bind, Injector, OpaqueToken;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, StringMapWrapper, Map;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "../metric.dart" show Metric;

class MultiMetric extends Metric {
  static createBindings(childTokens) {
    return [
      bind(_CHILDREN)
          .toAsyncFactory((injector) => PromiseWrapper.all(ListWrapper.map(
              childTokens, (token) => injector.asyncGet(token))), [
        Injector
      ]),
      bind(MultiMetric)
          .toFactory((children) => new MultiMetric(children), [
        _CHILDREN
      ])
    ];
  }
  List _metrics;
  MultiMetric(metrics) : super() {
    /* super call moved to initializer */;
    this._metrics = metrics;
  } /**
   * Starts measuring
   */
  Future beginMeasure() {
    return PromiseWrapper
        .all(ListWrapper.map(this._metrics, (metric) => metric.beginMeasure()));
  } /**
   * Ends measuring and reports the data
   * since the begin call.
   * @param restart: Whether to restart right after this.
   */
  Future<Map> endMeasure(bool restart) {
    return PromiseWrapper
        .all(ListWrapper.map(
            this._metrics, (metric) => metric.endMeasure(restart)))
        .then((values) {
      return mergeStringMaps(values);
    });
  } /**
   * Describes the metrics provided by this metric implementation.
   * (e.g. units, ...)
   */
  Map describe() {
    return mergeStringMaps(this._metrics.map((metric) => metric.describe()));
  }
}
mergeStringMaps(maps) {
  var result = {};
  ListWrapper.forEach(maps, (map) {
    StringMapWrapper.forEach(map, (value, prop) {
      result[prop] = value;
    });
  });
  return result;
}
var _CHILDREN = new OpaqueToken("MultiMetric.children");
