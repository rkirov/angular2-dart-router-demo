library angular2.test.change_detection.change_detection_spec;

import "package:angular2/test_lib.dart"
    show ddescribe, describe, it, iit, xit, expect, beforeEach, afterEach;
import "package:angular2/change_detection.dart"
    show
        PreGeneratedChangeDetection,
        ChangeDetectorDefinition,
        ProtoChangeDetector,
        DynamicProtoChangeDetector;

class DummyChangeDetector extends ProtoChangeDetector {}
main() {
  describe("PreGeneratedChangeDetection", () {
    var proto;
    var def;
    beforeEach(() {
      proto = new DummyChangeDetector();
      def = new ChangeDetectorDefinition("id", null, [], [], []);
    });
    it("should return a proto change detector when one is available", () {
      var map = {"id": (registry) => proto};
      var cd = new PreGeneratedChangeDetection(null, map);
      expect(cd.createProtoChangeDetector(def)).toBe(proto);
    });
    it("should delegate to dynamic change detection otherwise", () {
      var cd = new PreGeneratedChangeDetection(null, {});
      expect(cd.createProtoChangeDetector(def))
          .toBeAnInstanceOf(DynamicProtoChangeDetector);
    });
  });
}
