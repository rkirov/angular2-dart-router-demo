library benchmarks.src.compiler.compiler_benchmark;

import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;
import "package:angular2/src/facade/lang.dart" show Type;
import "package:angular2/src/facade/browser.dart" show document;
import "package:angular2/src/render/dom/shadow_dom/native_shadow_dom_strategy.dart"
    show NativeShadowDomStrategy;
import "package:angular2/change_detection.dart"
    show Parser, Lexer, DynamicChangeDetection;
import "package:angular2/src/core/compiler/compiler.dart"
    show Compiler, CompilerCache;
import "package:angular2/src/core/compiler/directive_metadata_reader.dart"
    show DirectiveMetadataReader;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/render/dom/compiler/template_loader.dart"
    show TemplateLoader;
import "package:angular2/src/core/compiler/template_resolver.dart"
    show TemplateResolver;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/render/dom/shadow_dom/style_url_resolver.dart"
    show StyleUrlResolver;
import "package:angular2/src/core/compiler/component_url_mapper.dart"
    show ComponentUrlMapper;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, bindAction;
import "package:angular2/src/core/compiler/proto_view_factory.dart"
    show ProtoViewFactory;
import "package:angular2/src/render/dom/direct_dom_renderer.dart"
    show DirectDomRenderer;
import "package:angular2/src/render/dom/compiler/compiler.dart" as rc;

setupReflector() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  reflector.registerGetters({
    "inter0": (a) => a.inter0,
    "inter1": (a) => a.inter1,
    "inter2": (a) => a.inter2,
    "inter3": (a) => a.inter3,
    "inter4": (a) => a.inter4,
    "value0": (a) => a.value0,
    "value1": (a) => a.value1,
    "value2": (a) => a.value2,
    "value3": (a) => a.value3,
    "value4": (a) => a.value4,
    "prop": (a) => a.prop
  });
  reflector.registerSetters({
    "inter0": (a, v) => a.inter0 = v,
    "inter1": (a, v) => a.inter1 = v,
    "inter2": (a, v) => a.inter2 = v,
    "inter3": (a, v) => a.inter3 = v,
    "inter4": (a, v) => a.inter4 = v,
    "value0": (a, v) => a.value0 = v,
    "value1": (a, v) => a.value1 = v,
    "value2": (a, v) => a.value2 = v,
    "value3": (a, v) => a.value3 = v,
    "value4": (a, v) => a.value4 = v,
    "attr0": (a, v) => a.attr0 = v,
    "attr1": (a, v) => a.attr1 = v,
    "attr2": (a, v) => a.attr2 = v,
    "attr3": (a, v) => a.attr3 = v,
    "attr4": (a, v) => a.attr4 = v,
    "prop": (a, v) => a.prop = v
  });
}
main() {
  BrowserDomAdapter.makeCurrent();
  var count = getIntParameter("elements");
  setupReflector();
  var reader = new DirectiveMetadataReader();
  var cache = new CompilerCache();
  var templateResolver = new FakeTemplateResolver();
  var urlResolver = new UrlResolver();
  var styleUrlResolver = new StyleUrlResolver(urlResolver);
  var shadowDomStrategy = new NativeShadowDomStrategy(styleUrlResolver);
  var renderer = new DirectDomRenderer(new rc.DefaultCompiler(
      new Parser(new Lexer()), shadowDomStrategy,
      new TemplateLoader(null, urlResolver)), null, null, shadowDomStrategy);
  var compiler = new Compiler(reader, cache, templateResolver,
      new ComponentUrlMapper(), urlResolver, renderer,
      new ProtoViewFactory(new DynamicChangeDetection(null)));
  var templateNoBindings = createTemplateHtml("templateNoBindings", count);
  var templateWithBindings = createTemplateHtml("templateWithBindings", count);
  compileNoBindings() {
    templateResolver.setTemplateHtml(templateNoBindings);
    cache.clear();
    compiler.compile(BenchmarkComponent);
  }
  compileWithBindings() {
    templateResolver.setTemplateHtml(templateWithBindings);
    cache.clear();
    compiler.compile(BenchmarkComponent);
  }
  bindAction("#compileNoBindings", compileNoBindings);
  bindAction("#compileWithBindings", compileWithBindings);
}
createTemplateHtml(templateId, repeatCount) {
  var template = DOM.querySelectorAll(document, '''#${ templateId}''')[0];
  var content = DOM.getInnerHTML(template);
  var result = "";
  for (var i = 0; i < repeatCount; i++) {
    result += content;
  }
  return result;
}
@Directive(selector: "[dir0]", properties: const {"prop": "attr0"})
class Dir0 {}
@Directive(selector: "[dir1]", properties: const {"prop": "attr1"})
class Dir1 {
  Dir1(Dir0 dir0) {}
}
@Directive(selector: "[dir2]", properties: const {"prop": "attr2"})
class Dir2 {
  Dir2(Dir1 dir1) {}
}
@Directive(selector: "[dir3]", properties: const {"prop": "attr3"})
class Dir3 {
  Dir3(Dir2 dir2) {}
}
@Directive(selector: "[dir4]", properties: const {"prop": "attr4"})
class Dir4 {
  Dir4(Dir3 dir3) {}
}
@Component()
class BenchmarkComponent {}
class FakeTemplateResolver extends TemplateResolver {
  View _template;
  FakeTemplateResolver() : super() {
    /* super call moved to initializer */;
  }
  setTemplateHtml(String html) {
    this._template =
        new View(template: html, directives: [Dir0, Dir1, Dir2, Dir3, Dir4]);
  }
  View resolve(Type component) {
    return this._template;
  }
}
