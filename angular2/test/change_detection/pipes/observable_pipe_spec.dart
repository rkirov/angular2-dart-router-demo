library angular2.test.change_detection.pipes.observable_pipe_spec;

import "package:angular2/test_lib.dart"
    show
        ddescribe,
        describe,
        it,
        iit,
        xit,
        expect,
        beforeEach,
        afterEach,
        AsyncTestCompleter,
        inject,
        proxy,
        SpyObject;
import "package:angular2/src/change_detection/pipes/pipe.dart"
    show WrappedValue;
import "package:angular2/src/change_detection/pipes/observable_pipe.dart"
    show ObservablePipe;
import "package:angular2/src/change_detection/change_detector_ref.dart"
    show ChangeDetectorRef;
import "package:angular2/src/facade/async.dart"
    show EventEmitter, Stream, ObservableWrapper, PromiseWrapper;

main() {
  describe("ObservablePipe", () {
    var emitter;
    var pipe;
    var ref;
    var message = new Object();
    beforeEach(() {
      emitter = new EventEmitter();
      ref = new SpyChangeDetectorRef();
      pipe = new ObservablePipe(ref);
    });
    describe("supports", () {
      it("should support observables", () {
        expect(pipe.supports(emitter)).toBe(true);
      });
      it("should not support other objects", () {
        expect(pipe.supports("string")).toBe(false);
        expect(pipe.supports(null)).toBe(false);
      });
    });
    describe("transform", () {
      it("should return null when subscribing to an observable", () {
        expect(pipe.transform(emitter)).toBe(null);
      });
      it("should return the latest available value wrapped", inject(
          [AsyncTestCompleter], (async) {
        pipe.transform(emitter);
        ObservableWrapper.callNext(emitter, message);
        PromiseWrapper.setTimeout(() {
          expect(pipe.transform(emitter)).toEqual(new WrappedValue(message));
          async.done();
        }, 0);
      }));
      it("should return same value when nothing has changed since the last call",
          inject([AsyncTestCompleter], (async) {
        pipe.transform(emitter);
        ObservableWrapper.callNext(emitter, message);
        PromiseWrapper.setTimeout(() {
          pipe.transform(emitter);
          expect(pipe.transform(emitter)).toBe(message);
          async.done();
        }, 0);
      }));
      it("should dispose of the existing subscription when subscribing to a new observable",
          inject([AsyncTestCompleter], (async) {
        pipe.transform(emitter);
        var newEmitter = new EventEmitter();
        expect(pipe.transform(newEmitter)).toBe(null);
        // this should not affect the pipe
        ObservableWrapper.callNext(emitter, message);
        PromiseWrapper.setTimeout(() {
          expect(pipe.transform(newEmitter)).toBe(null);
          async.done();
        }, 0);
      }));
      it("should request a change detection check upon receiving a new value",
          inject([AsyncTestCompleter], (async) {
        pipe.transform(emitter);
        ObservableWrapper.callNext(emitter, message);
        PromiseWrapper.setTimeout(() {
          expect(ref.spy("requestCheck")).toHaveBeenCalled();
          async.done();
        }, 0);
      }));
    });
    describe("onDestroy", () {
      it("should do nothing when no subscription", () {
        pipe.onDestroy();
      });
      it("should dispose of the existing subscription", inject(
          [AsyncTestCompleter], (async) {
        pipe.transform(emitter);
        pipe.onDestroy();
        ObservableWrapper.callNext(emitter, message);
        PromiseWrapper.setTimeout(() {
          expect(pipe.transform(emitter)).toBe(null);
          async.done();
        }, 0);
      }));
    });
  });
}
@proxy
class SpyChangeDetectorRef extends SpyObject implements ChangeDetectorRef {
  SpyChangeDetectorRef() : super(ChangeDetectorRef) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
