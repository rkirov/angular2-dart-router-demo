library angular2.test.render.dom.compiler.text_interpolation_parser_spec;

import "package:angular2/test_lib.dart"
    show describe, beforeEach, expect, it, iit, ddescribe, el;
import "package:angular2/src/render/dom/compiler/text_interpolation_parser.dart"
    show TextInterpolationParser;
import "package:angular2/src/render/dom/compiler/compile_pipeline.dart"
    show CompilePipeline;
import "package:angular2/src/facade/collection.dart"
    show MapWrapper, ListWrapper;
import "package:angular2/change_detection.dart" show Lexer, Parser;
import "pipeline_spec.dart" show IgnoreChildrenStep;

main() {
  describe("TextInterpolationParser", () {
    createPipeline() {
      return new CompilePipeline([
        new IgnoreChildrenStep(),
        new TextInterpolationParser(new Parser(new Lexer()))
      ]);
    }
    process(element) {
      return ListWrapper.map(createPipeline().process(element),
          (compileElement) => compileElement.inheritedElementBinder);
    }
    assertTextBinding(elementBinder, bindingIndex, nodeIndex, expression) {
      expect(elementBinder.textBindings[bindingIndex].source)
          .toEqual(expression);
      expect(elementBinder.textBindingIndices[bindingIndex]).toEqual(nodeIndex);
    }
    it("should find text interpolation in normal elements", () {
      var result = process(el("<div>{{expr1}}<span></span>{{expr2}}</div>"))[0];
      assertTextBinding(result, 0, 0, "{{expr1}}");
      assertTextBinding(result, 1, 2, "{{expr2}}");
    });
    it("should find text interpolation in template elements", () {
      var result = process(
          el("<template>{{expr1}}<span></span>{{expr2}}</template>"))[0];
      assertTextBinding(result, 0, 0, "{{expr1}}");
      assertTextBinding(result, 1, 2, "{{expr2}}");
    });
    it("should allow multiple expressions", () {
      var result = process(el("<div>{{expr1}}{{expr2}}</div>"))[0];
      assertTextBinding(result, 0, 0, "{{expr1}}{{expr2}}");
    });
    it("should not interpolate when compileChildren is false", () {
      var results = process(el(
          "<div>{{included}}<span ignore-children>{{excluded}}</span></div>"));
      assertTextBinding(results[0], 0, 0, "{{included}}");
      expect(results[1]).toBe(results[0]);
    });
    it("should allow fixed text before, in between and after expressions", () {
      var result = process(el("<div>a{{expr1}}b{{expr2}}c</div>"))[0];
      assertTextBinding(result, 0, 0, "a{{expr1}}b{{expr2}}c");
    });
    it("should escape quotes in fixed parts", () {
      var result = process(el("<div>'\"a{{expr1}}</div>"))[0];
      assertTextBinding(result, 0, 0, "'\"a{{expr1}}");
    });
  });
}
