library benchpress.test.reporter.multi_reporter_spec;

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
import "package:angular2/src/facade/lang.dart" show DateWrapper;
import "package:benchpress/common.dart"
    show Reporter, MultiReporter, bind, Injector, MeasureValues;

main() {
  createReporters(ids) {
    return Injector
        .resolveAndCreate([
      ListWrapper.map(ids, (id) => bind(id).toValue(new MockReporter(id))),
      MultiReporter.createBindings(ids)
    ])
        .asyncGet(MultiReporter);
  }
  describe("multi reporter", () {
    it("should reportMeasureValues to all", inject([AsyncTestCompleter],
        (async) {
      var mv = new MeasureValues(0, DateWrapper.now(), {});
      createReporters(["m1", "m2"])
          .then((r) => r.reportMeasureValues(mv))
          .then((values) {
        expect(values)
            .toEqual([{"id": "m1", "values": mv}, {"id": "m2", "values": mv}]);
        async.done();
      });
    }));
    it("should reportSample to call", inject([AsyncTestCompleter], (async) {
      var completeSample = [
        new MeasureValues(0, DateWrapper.now(), {}),
        new MeasureValues(1, DateWrapper.now(), {})
      ];
      var validSample = [completeSample[1]];
      createReporters(["m1", "m2"])
          .then((r) => r.reportSample(completeSample, validSample))
          .then((values) {
        expect(values).toEqual([
          {
            "id": "m1",
            "completeSample": completeSample,
            "validSample": validSample
          },
          {
            "id": "m2",
            "completeSample": completeSample,
            "validSample": validSample
          }
        ]);
        async.done();
      });
    }));
  });
}
class MockReporter extends Reporter {
  String _id;
  MockReporter(id) : super() {
    /* super call moved to initializer */;
    this._id = id;
  }
  Future reportMeasureValues(MeasureValues values) {
    return PromiseWrapper.resolve({"id": this._id, "values": values});
  }
  Future reportSample(
      List<MeasureValues> completeSample, List<MeasureValues> validSample) {
    return PromiseWrapper.resolve({
      "id": this._id,
      "completeSample": completeSample,
      "validSample": validSample
    });
  }
}
