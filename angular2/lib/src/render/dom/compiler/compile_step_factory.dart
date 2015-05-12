library angular2.src.render.dom.compiler.compile_step_factory;

import "package:angular2/src/facade/collection.dart" show List;
import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/change_detection.dart" show Parser;
import "../../api.dart" show ViewDefinition;
import "compile_step.dart" show CompileStep;
import "property_binding_parser.dart" show PropertyBindingParser;
import "text_interpolation_parser.dart" show TextInterpolationParser;
import "directive_parser.dart" show DirectiveParser;
import "view_splitter.dart" show ViewSplitter;
import "../shadow_dom/shadow_dom_compile_step.dart" show ShadowDomCompileStep;
import "../shadow_dom/shadow_dom_strategy.dart" show ShadowDomStrategy;

class CompileStepFactory {
  List<CompileStep> createSteps(
      ViewDefinition template, List<Future> subTaskPromises) {
    return null;
  }
}
class DefaultStepFactory extends CompileStepFactory {
  Parser _parser;
  ShadowDomStrategy _shadowDomStrategy;
  DefaultStepFactory(Parser parser, shadowDomStrategy) : super() {
    /* super call moved to initializer */;
    this._parser = parser;
    this._shadowDomStrategy = shadowDomStrategy;
  }
  createSteps(ViewDefinition template, List<Future> subTaskPromises) {
    return [
      new ViewSplitter(this._parser),
      new PropertyBindingParser(this._parser),
      new DirectiveParser(this._parser, template.directives),
      new TextInterpolationParser(this._parser),
      new ShadowDomCompileStep(
          this._shadowDomStrategy, template, subTaskPromises)
    ];
  }
}
