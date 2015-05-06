library angular2.src.render.dom.compiler.compiler;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "package:angular2/src/facade/lang.dart" show BaseException;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "../../api.dart" show ViewDefinition, ProtoViewDto, DirectiveMetadata;
import "compile_pipeline.dart" show CompilePipeline;
import "package:angular2/src/render/dom/compiler/template_loader.dart"
    show TemplateLoader;
import "compile_step_factory.dart" show CompileStepFactory, DefaultStepFactory;
import "package:angular2/change_detection.dart" show Parser;
import "../shadow_dom/shadow_dom_strategy.dart"
    show
        ShadowDomStrategy; /**
 * The compiler loads and translates the html templates of components into
 * nested ProtoViews. To decompose its functionality it uses
 * the CompilePipeline and the CompileSteps.
 */

class Compiler {
  TemplateLoader _templateLoader;
  CompileStepFactory _stepFactory;
  Compiler(CompileStepFactory stepFactory, TemplateLoader templateLoader) {
    this._templateLoader = templateLoader;
    this._stepFactory = stepFactory;
  }
  Future<ProtoViewDto> compile(ViewDefinition template) {
    var tplPromise = this._templateLoader.load(template);
    return PromiseWrapper.then(tplPromise,
        (el) => this._compileTemplate(template, el), (_) {
      throw new BaseException(
          '''Failed to load the template "${ template . componentId}"''');
    });
  }
  Future<ProtoViewDto> compileHost(DirectiveMetadata directiveMetadata) {
    var hostViewDef = new ViewDefinition(
        componentId: directiveMetadata.id,
        absUrl: null,
        template: null,
        directives: [directiveMetadata]);
    var element = DOM.createElement(directiveMetadata.selector);
    return this._compileTemplate(hostViewDef, element);
  }
  Future<ProtoViewDto> _compileTemplate(ViewDefinition viewDef, tplElement) {
    var subTaskPromises = [];
    var pipeline = new CompilePipeline(
        this._stepFactory.createSteps(viewDef, subTaskPromises));
    var compileElements = pipeline.process(tplElement, viewDef.componentId);
    var protoView = compileElements[0].inheritedProtoView.build();
    if (subTaskPromises.length > 0) {
      return PromiseWrapper.all(subTaskPromises).then((_) => protoView);
    } else {
      return PromiseWrapper.resolve(protoView);
    }
  }
}
@Injectable()
class DefaultCompiler extends Compiler {
  DefaultCompiler(Parser parser, ShadowDomStrategy shadowDomStrategy,
      TemplateLoader templateLoader)
      : super(
          new DefaultStepFactory(parser, shadowDomStrategy), templateLoader) {
    /* super call moved to initializer */;
  }
}
