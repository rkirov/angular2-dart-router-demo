library angular2.test.core.compiler.directive_metadata_reader_spec;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:angular2/test_lib.dart"
    show ddescribe, describe, it, iit, expect, beforeEach;
import "package:angular2/src/core/compiler/directive_metadata_reader.dart"
    show DirectiveMetadataReader;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive, Component;
import "package:angular2/src/core/compiler/directive_metadata.dart"
    show DirectiveMetadata;
import "package:angular2/di.dart" show Injectable, Injector;

@Injectable()
class SomeInjectable {}
@Directive(selector: "someDirective")
class SomeDirective {}
@Component(selector: "someComponent", injectables: const [SomeInjectable])
class SomeComponent {}
class SomeDirectiveWithoutAnnotation {}
main() {
  describe("DirectiveMetadataReader", () {
    var reader;
    beforeEach(() {
      reader = new DirectiveMetadataReader();
    });
    it("should read out the Directive annotation", () {
      var directiveMetadata = reader.read(SomeDirective);
      expect(directiveMetadata).toEqual(new DirectiveMetadata(
          SomeDirective, new Directive(selector: "someDirective"), null));
    });
    it("should read out the Component annotation", () {
      var m = reader.read(SomeComponent);
      // For some reason `toEqual` fails to compare ResolvedBinding objects.

      // Have to decompose and compare.
      expect(m.type).toEqual(SomeComponent);
      expect(m.annotation).toEqual(new Component(
          selector: "someComponent", injectables: [SomeInjectable]));
      var resolvedList = ListWrapper.reduce(m.resolvedInjectables,
          (prev, elem) {
        if (isPresent(elem)) {
          ListWrapper.push(prev, elem);
        }
        return prev;
      }, []);
      expect(resolvedList.length).toBe(1);
      expect(resolvedList[0].key.token).toBe(SomeInjectable);
    });
    it("should throw if not matching annotation is found", () {
      expect(() {
        reader.read(SomeDirectiveWithoutAnnotation);
      }).toThrowError(
          "No Directive annotation found on SomeDirectiveWithoutAnnotation");
    });
  });
}
