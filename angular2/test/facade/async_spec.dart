library angular2.test.facade.async_spec;

import "package:angular2/test_lib.dart"
    show
        describe,
        it,
        expect,
        beforeEach,
        ddescribe,
        iit,
        xit,
        el,
        SpyObject,
        AsyncTestCompleter,
        inject,
        IS_DARTIUM;
import "package:angular2/src/facade/async.dart"
    show ObservableWrapper, EventEmitter, PromiseWrapper;

main() {
  describe("EventEmitter", () {
    EventEmitter emitter;
    beforeEach(() {
      emitter = new EventEmitter();
    });
    it("should call the next callback", inject([AsyncTestCompleter], (async) {
      ObservableWrapper.subscribe(emitter, (value) {
        expect(value).toEqual(99);
        async.done();
      });
      ObservableWrapper.callNext(emitter, 99);
    }));
    it("should call the throw callback", inject([AsyncTestCompleter], (async) {
      ObservableWrapper.subscribe(emitter, (_) {}, (error) {
        expect(error).toEqual("Boom");
        async.done();
      });
      ObservableWrapper.callThrow(emitter, "Boom");
    }));
    it("should work when no throw callback is provided", inject(
        [AsyncTestCompleter], (async) {
      ObservableWrapper.subscribe(emitter, (_) {}, (_) {
        async.done();
      });
      ObservableWrapper.callThrow(emitter, "Boom");
    }));
    it("should call the return callback", inject([AsyncTestCompleter], (async) {
      ObservableWrapper.subscribe(emitter, (_) {}, (_) {}, () {
        async.done();
      });
      ObservableWrapper.callReturn(emitter);
    }));
    it("should subscribe to the wrapper asynchronously", () {
      var called = false;
      ObservableWrapper.subscribe(emitter, (value) {
        called = true;
      });
      ObservableWrapper.callNext(emitter, 99);
      expect(called).toBe(false);
    });
  });
}
