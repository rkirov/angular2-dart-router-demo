library angular2.test.change_detection.pipes.pipe_registry_spec;

import "package:angular2/test_lib.dart"
    show ddescribe, describe, it, iit, xit, expect, beforeEach, afterEach;
import "package:angular2/src/change_detection/pipes/pipe_registry.dart"
    show PipeRegistry;
import "package:angular2/src/change_detection/pipes/pipe.dart" show Pipe;

main() {
  describe("pipe registry", () {
    var firstPipe = new Pipe();
    var secondPipe = new Pipe();
    it("should return the first pipe supporting the data type", () {
      var r = new PipeRegistry({
        "type": [
          new PipeFactory(false, firstPipe),
          new PipeFactory(true, secondPipe)
        ]
      });
      expect(r.get("type", "some object", null)).toBe(secondPipe);
    });
    it("should throw when no matching type", () {
      var r = new PipeRegistry({});
      expect(() => r.get("unknown", "some object", null)).toThrowError(
          '''Cannot find \'unknown\' pipe supporting object \'some object\'''');
    });
    it("should throw when no matching pipe", () {
      var r = new PipeRegistry({"type": []});
      expect(() => r.get("type", "some object", null)).toThrowError(
          '''Cannot find \'type\' pipe supporting object \'some object\'''');
    });
  });
}
class PipeFactory {
  bool shouldSupport;
  dynamic pipe;
  PipeFactory(bool shouldSupport, dynamic pipe) {
    this.shouldSupport = shouldSupport;
    this.pipe = pipe;
  }
  bool supports(obj) {
    return this.shouldSupport;
  }
  Pipe create(cdRef) {
    return this.pipe;
  }
}
