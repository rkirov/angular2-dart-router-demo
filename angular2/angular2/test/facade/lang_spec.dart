library angular2.test.facade.lang_spec;

import "package:angular2/test_lib.dart"
    show describe, it, expect, beforeEach, ddescribe, iit, xit, el;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:angular2/src/facade/lang.dart"
    show isPresent, RegExpWrapper, RegExpMatcherWrapper;

main() {
  describe("RegExp", () {
    it("should expose the index for each match", () {
      var re = RegExpWrapper.create("(!)");
      var matcher = RegExpWrapper.matcher(re, "0!23!567!!");
      var indexes = [];
      var m;
      while (isPresent(m = RegExpMatcherWrapper.next(matcher))) {
        ListWrapper.push(indexes, m.index);
        expect(m[0]).toEqual("!");
        expect(m[1]).toEqual("!");
        expect(m.length).toBe(2);
      }
      expect(indexes).toEqual([1, 4, 8, 9]);
    });
  });
}
