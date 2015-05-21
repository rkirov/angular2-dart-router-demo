library angular2.test.core.compiler.directive_metadata_reader_spec;

import "package:angular2/test_lib.dart"
    show ddescribe, describe, it, iit, expect, beforeEach;
import "package:angular2/src/core/compiler/directive_resolver.dart"
    show DirectiveResolver;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;

@Directive(selector: "someDirective")
class SomeDirective {}
class SomeDirectiveWithoutAnnotation {}
main() {
  describe("DirectiveResolver", () {
    var reader;
    beforeEach(() {
      reader = new DirectiveResolver();
    });
    it("should read out the Directive annotation", () {
      var directiveMetadata = reader.resolve(SomeDirective);
      expect(directiveMetadata)
          .toEqual(new Directive(selector: "someDirective"));
    });
    it("should throw if not matching annotation is found", () {
      expect(() {
        reader.resolve(SomeDirectiveWithoutAnnotation);
      }).toThrowError(
          "No Directive annotation found on SomeDirectiveWithoutAnnotation");
    });
  });
}
