library angular2.src.test_lib.test_injector;

import "package:angular2/di.dart" show bind;
import "package:angular2/src/core/compiler/compiler.dart"
    show Compiler, CompilerCache;
import "package:angular2/src/reflection/reflection.dart"
    show Reflector, reflector;
import "package:angular2/change_detection.dart"
    show
        Parser,
        Lexer,
        ChangeDetection,
        DynamicChangeDetection,
        PipeRegistry,
        defaultPipeRegistry;
import "package:angular2/src/core/exception_handler.dart" show ExceptionHandler;
import "package:angular2/src/render/dom/compiler/template_loader.dart"
    show TemplateLoader;
import "package:angular2/src/core/compiler/template_resolver.dart"
    show TemplateResolver;
import "package:angular2/src/core/compiler/directive_metadata_reader.dart"
    show DirectiveMetadataReader;
import "package:angular2/src/core/compiler/dynamic_component_loader.dart"
    show DynamicComponentLoader;
import "package:angular2/src/render/dom/shadow_dom/shadow_dom_strategy.dart"
    show ShadowDomStrategy;
import "package:angular2/src/render/dom/shadow_dom/emulated_unscoped_shadow_dom_strategy.dart"
    show EmulatedUnscopedShadowDomStrategy;
import "package:angular2/src/services/xhr.dart" show XHR;
import "package:angular2/src/core/compiler/component_url_mapper.dart"
    show ComponentUrlMapper;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/render/dom/shadow_dom/style_url_resolver.dart"
    show StyleUrlResolver;
import "package:angular2/src/render/dom/shadow_dom/style_inliner.dart"
    show StyleInliner;
import "package:angular2/src/core/zone/ng_zone.dart" show NgZone;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/render/dom/events/event_manager.dart"
    show EventManager, DomEventsPlugin;
import "package:angular2/src/mock/template_resolver_mock.dart"
    show MockTemplateResolver;
import "package:angular2/src/mock/xhr_mock.dart" show MockXHR;
import "package:angular2/src/mock/ng_zone_mock.dart" show MockNgZone;
import "test_bed.dart" show TestBed;
import "package:angular2/di.dart" show Injector;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/facade/lang.dart" show FunctionWrapper;
import "package:angular2/src/core/compiler/view_pool.dart"
    show AppViewPool, APP_VIEW_POOL_CAPACITY;
import "package:angular2/src/core/compiler/view_manager.dart"
    show AppViewManager;
import "package:angular2/src/core/compiler/view_manager_utils.dart"
    show AppViewManagerUtils;
import "package:angular2/src/core/compiler/proto_view_factory.dart"
    show ProtoViewFactory;
import "package:angular2/src/render/api.dart" show RenderCompiler, Renderer;
import "package:angular2/src/render/dom/dom_renderer.dart"
    show DomRenderer, DOCUMENT_TOKEN;
import "package:angular2/src/render/dom/compiler/compiler.dart"
    show DefaultDomCompiler;

/**
 * Returns the root injector bindings.
 *
 * This must be kept in sync with the _rootBindings in application.js
 *
 * @returns {any[]}
 */
_getRootBindings() {
  return [bind(Reflector).toValue(reflector)];
}
/**
 * Returns the application injector bindings.
 *
 * This must be kept in sync with _injectorBindings() in application.js
 *
 * @returns {any[]}
 */
_getAppBindings() {
  var appDoc;
  // The document is only available in browser environment
  try {
    appDoc = DOM.defaultDoc();
  } catch (e) {
    appDoc = null;
  }
  return [
    bind(DOCUMENT_TOKEN).toValue(appDoc),
    bind(ShadowDomStrategy).toFactory((styleUrlResolver, doc) =>
        new EmulatedUnscopedShadowDomStrategy(styleUrlResolver, doc.head), [
      StyleUrlResolver,
      DOCUMENT_TOKEN
    ]),
    DomRenderer,
    DefaultDomCompiler,
    bind(Renderer).toAlias(DomRenderer),
    bind(RenderCompiler).toAlias(DefaultDomCompiler),
    ProtoViewFactory,
    AppViewPool,
    AppViewManager,
    AppViewManagerUtils,
    bind(APP_VIEW_POOL_CAPACITY).toValue(500),
    Compiler,
    CompilerCache,
    bind(TemplateResolver).toClass(MockTemplateResolver),
    bind(PipeRegistry).toValue(defaultPipeRegistry),
    bind(ChangeDetection).toClass(DynamicChangeDetection),
    TemplateLoader,
    DynamicComponentLoader,
    DirectiveMetadataReader,
    Parser,
    Lexer,
    ExceptionHandler,
    bind(XHR).toClass(MockXHR),
    ComponentUrlMapper,
    UrlResolver,
    StyleUrlResolver,
    StyleInliner,
    TestBed,
    bind(NgZone).toClass(MockNgZone),
    bind(EventManager).toFactory((zone) {
      var plugins = [new DomEventsPlugin()];
      return new EventManager(plugins, zone);
    }, [NgZone])
  ];
}
Injector createTestInjector(List bindings) {
  var rootInjector = Injector.resolveAndCreate(_getRootBindings());
  return rootInjector
      .resolveAndCreateChild(ListWrapper.concat(_getAppBindings(), bindings));
}
/**
 * Allows injecting dependencies in `beforeEach()` and `it()`.
 *
 * Example:
 *
 * ```
 * beforeEach(inject([Dependency, AClass], (dep, object) => {
 *   // some code that uses `dep` and `object`
 *   // ...
 * }));
 *
 * it('...', inject([AClass, AsyncTestCompleter], (object, async) => {
 *   object.doSomething().then(() => {
 *     expect(...);
 *     async.done();
 *   });
 * })
 * ```
 *
 * Notes:
 * - injecting an `AsyncTestCompleter` allow completing async tests - this is the equivalent of
 *   adding a `done` parameter in Jasmine,
 * - inject is currently a function because of some Traceur limitation the syntax should eventually
 *   becomes `it('...', @Inject (object: AClass, async: AsyncTestCompleter) => { ... });`
 *
 * @param {Array} tokens
 * @param {Function} fn
 * @return {FunctionWithParamTokens}
 * @exportedAs angular2/test
 */
FunctionWithParamTokens inject(List tokens, Function fn) {
  return new FunctionWithParamTokens(tokens, fn);
}
class FunctionWithParamTokens {
  List _tokens;
  Function _fn;
  FunctionWithParamTokens(List tokens, Function fn) {
    this._tokens = tokens;
    this._fn = fn;
  }
  void execute(Injector injector) {
    var params = ListWrapper.map(this._tokens, (t) => injector.get(t));
    FunctionWrapper.apply(this._fn, params);
  }
}
