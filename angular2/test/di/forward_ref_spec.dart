library angular2.test.di.forward_ref_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        describe,
        expect,
        iit,
        inject,
        it,
        xit;
import "package:angular2/di.dart" show forwardRef, resolveForwardRef;
import "package:angular2/src/facade/lang.dart" show Type;

main() {
  describe("forwardRef", () {
    it("should wrap and unwrap the reference", () {
      var ref = forwardRef(() => String);
      expect(ref is Type).toBe(true);
      expect(resolveForwardRef(ref)).toBe(String);
    });
  });
}
