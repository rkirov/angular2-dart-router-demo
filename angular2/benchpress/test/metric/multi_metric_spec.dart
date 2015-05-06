library benchpress.test.metric.multi_metric_spec;

import "package:angular2/test_lib.dart"
    show
        afterEach,
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        describe,
        expect,
        iit,
        inject,
        it,
        xit;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "package:benchpress/common.dart"
    show Metric, MultiMetric, bind, Injector;

main() {
  createMetric(ids) {
    return Injector
        .resolveAndCreate([
      ListWrapper.map(ids, (id) => bind(id).toValue(new MockMetric(id))),
      MultiMetric.createBindings(ids)
    ])
        .asyncGet(MultiMetric);
  }
  describe("multi metric", () {
    it("should merge descriptions", inject([AsyncTestCompleter], (async) {
      createMetric(["m1", "m2"]).then((m) {
        expect(m.describe()).toEqual({"m1": "describe", "m2": "describe"});
        async.done();
      });
    }));
    it("should merge all beginMeasure calls", inject([AsyncTestCompleter],
        (async) {
      createMetric(["m1", "m2"]).then((m) => m.beginMeasure()).then((values) {
        expect(values).toEqual(["m1_beginMeasure", "m2_beginMeasure"]);
        async.done();
      });
    }));
    [false, true].forEach((restartFlag) {
      it('''should merge all endMeasure calls for restart=${ restartFlag}''',
          inject([AsyncTestCompleter], (async) {
        createMetric(["m1", "m2"])
            .then((m) => m.endMeasure(restartFlag))
            .then((values) {
          expect(values).toEqual(
              {"m1": {"restart": restartFlag}, "m2": {"restart": restartFlag}});
          async.done();
        });
      }));
    });
  });
}
class MockMetric extends Metric {
  String _id;
  MockMetric(id) : super() {
    /* super call moved to initializer */;
    this._id = id;
  }
  Future beginMeasure() {
    return PromiseWrapper.resolve('''${ this . _id}_beginMeasure''');
  }
  Future<Map> endMeasure(bool restart) {
    var result = {};
    result[this._id] = {"restart": restart};
    return PromiseWrapper.resolve(result);
  }
  Map describe() {
    var result = {};
    result[this._id] = "describe";
    return result;
  }
}
