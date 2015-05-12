library angular2.test.core.annotations.annotations_spec;

import "package:angular2/test_lib.dart"
    show ddescribe, describe, it, iit, expect, beforeEach;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive, onChange;

class DummyDirective extends Directive {
  DummyDirective({lifecycle}) : super(lifecycle: lifecycle) {
    /* super call moved to initializer */;
  }
}
main() {
  describe("Directive", () {
    describe("lifecycle", () {
      it("should be false when no lifecycle specified", () {
        var d = new DummyDirective();
        expect(d.hasLifecycleHook(onChange)).toBe(false);
      });
      it("should be false when the lifecycle does not contain the hook", () {
        var d = new DummyDirective(lifecycle: []);
        expect(d.hasLifecycleHook(onChange)).toBe(false);
      });
      it("should be true otherwise", () {
        var d = new DummyDirective(lifecycle: [onChange]);
        expect(d.hasLifecycleHook(onChange)).toBe(true);
      });
    });
  });
}
