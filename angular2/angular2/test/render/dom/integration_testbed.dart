library angular2.test.render.dom.integration_testbed;

import "package:angular2/src/facade/lang.dart"
    show isBlank, isPresent, BaseException;
import "package:angular2/src/facade/collection.dart"
    show MapWrapper, ListWrapper, List, Map;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/change_detection.dart" show Parser, Lexer;
import "package:angular2/src/render/dom/direct_dom_renderer.dart"
    show DirectDomRenderer;
import "package:angular2/src/render/dom/compiler/compiler.dart" show Compiler;
import "package:angular2/src/render/api.dart"
    show
        RenderProtoViewRef,
        ProtoViewDto,
        ViewDefinition,
        RenderViewContainerRef,
        EventDispatcher,
        DirectiveMetadata;
import "package:angular2/src/render/dom/compiler/compile_step_factory.dart"
    show DefaultStepFactory;
import "package:angular2/src/render/dom/compiler/template_loader.dart"
    show TemplateLoader;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/render/dom/shadow_dom/emulated_unscoped_shadow_dom_strategy.dart"
    show EmulatedUnscopedShadowDomStrategy;
import "package:angular2/src/render/dom/events/event_manager.dart"
    show EventManager, EventManagerPlugin;
import "package:angular2/src/core/zone/vm_turn_zone.dart" show VmTurnZone;
import "package:angular2/src/render/dom/shadow_dom/style_url_resolver.dart"
    show StyleUrlResolver;
import "package:angular2/src/render/dom/view/view_factory.dart"
    show ViewFactory;
import "package:angular2/src/render/dom/view/view_hydrator.dart"
    show RenderViewHydrator;

class IntegrationTestbed {
  var renderer;
  var parser;
  var eventPlugin;
  Map<String, ViewDefinition> _templates;
  IntegrationTestbed(
      {urlData, viewCacheCapacity, shadowDomStrategy, templates}) {
    this._templates = MapWrapper.create();
    if (isPresent(templates)) {
      ListWrapper.forEach(templates, (template) {
        MapWrapper.set(this._templates, template.componentId, template);
      });
    }
    var parser = new Parser(new Lexer());
    var urlResolver = new UrlResolver();
    if (isBlank(shadowDomStrategy)) {
      shadowDomStrategy = new EmulatedUnscopedShadowDomStrategy(
          new StyleUrlResolver(urlResolver), null);
    }
    var compiler = new Compiler(
        new DefaultStepFactory(parser, shadowDomStrategy),
        new FakeTemplateLoader(urlResolver, urlData));
    if (isBlank(viewCacheCapacity)) {
      viewCacheCapacity = 0;
    }
    if (isBlank(urlData)) {
      urlData = MapWrapper.create();
    }
    this.eventPlugin = new FakeEventManagerPlugin();
    var eventManager =
        new EventManager([this.eventPlugin], new FakeVmTurnZone());
    var viewFactory =
        new ViewFactory(viewCacheCapacity, eventManager, shadowDomStrategy);
    var viewHydrator =
        new RenderViewHydrator(eventManager, viewFactory, shadowDomStrategy);
    this.renderer = new DirectDomRenderer(
        compiler, viewFactory, viewHydrator, shadowDomStrategy);
  }
  Future<ProtoViewDto> compileRoot(componentMetadata) {
    return this.renderer
        .createHostProtoView(componentMetadata)
        .then((rootProtoView) {
      return this._compileNestedProtoViews(rootProtoView, [componentMetadata]);
    });
  }
  Future<ProtoViewDto> compile(componentId) {
    var childTemplate = MapWrapper.get(this._templates, componentId);
    if (isBlank(childTemplate)) {
      throw new BaseException('''No template for component ${ componentId}''');
    }
    return this.renderer.compile(childTemplate).then((protoView) {
      return this._compileNestedProtoViews(protoView, childTemplate.directives);
    });
  }
  Future<ProtoViewDto> _compileNestedProtoViews(protoView, directives) {
    var childComponentRenderPvRefs = [];
    var nestedPVPromises = [];
    ListWrapper.forEach(protoView.elementBinders, (elementBinder) {
      var nestedComponentId = null;
      ListWrapper.forEach(elementBinder.directives, (db) {
        var directiveMeta = directives[db.directiveIndex];
        if (identical(directiveMeta.type, DirectiveMetadata.COMPONENT_TYPE)) {
          nestedComponentId = directiveMeta.id;
        }
      });
      var nestedCall;
      if (isPresent(nestedComponentId)) {
        var childTemplate = MapWrapper.get(this._templates, nestedComponentId);
        if (isBlank(childTemplate)) {
          // dynamic component
          ListWrapper.push(childComponentRenderPvRefs, null);
        } else {
          nestedCall = this.compile(nestedComponentId);
        }
      } else if (isPresent(elementBinder.nestedProtoView)) {
        nestedCall = this._compileNestedProtoViews(
            elementBinder.nestedProtoView, directives);
      }
      if (isPresent(nestedCall)) {
        ListWrapper.push(nestedPVPromises, nestedCall.then((nestedPv) {
          elementBinder.nestedProtoView = nestedPv;
          if (isPresent(nestedComponentId)) {
            ListWrapper.push(childComponentRenderPvRefs, nestedPv.render);
          }
        }));
      }
    });
    if (nestedPVPromises.length > 0) {
      return PromiseWrapper.all(nestedPVPromises).then((_) {
        this.renderer.mergeChildComponentProtoViews(
            protoView.render, childComponentRenderPvRefs);
        return protoView;
      });
    } else {
      return PromiseWrapper.resolve(protoView);
    }
  }
}
class FakeTemplateLoader extends TemplateLoader {
  Map<String, String> _urlData;
  FakeTemplateLoader(urlResolver, urlData) : super(null, urlResolver) {
    /* super call moved to initializer */;
    this._urlData = urlData;
  }
  load(ViewDefinition template) {
    if (isPresent(template.template)) {
      return PromiseWrapper.resolve(DOM.createTemplate(template.template));
    }
    if (isPresent(template.absUrl)) {
      var content = this._urlData[template.absUrl];
      if (isPresent(content)) {
        return PromiseWrapper.resolve(DOM.createTemplate(content));
      }
    }
    return PromiseWrapper.reject("Load failed");
  }
}
class FakeVmTurnZone extends VmTurnZone {
  FakeVmTurnZone() : super(enableLongStackTrace: false) {
    /* super call moved to initializer */;
  }
  run(fn) {
    fn();
  }
  runOutsideAngular(fn) {
    fn();
  }
}
class FakeEventManagerPlugin extends EventManagerPlugin {
  Map _eventHandlers;
  FakeEventManagerPlugin() : super() {
    /* super call moved to initializer */;
    this._eventHandlers = MapWrapper.create();
  }
  dispatchEvent(eventName, event) {
    MapWrapper.get(this._eventHandlers, eventName)(event);
  }
  bool supports(String eventName) {
    return true;
  }
  addEventListener(
      element, String eventName, Function handler, bool shouldSupportBubble) {
    MapWrapper.set(this._eventHandlers, eventName, handler);
    return () {
      MapWrapper.delete(this._eventHandlers, eventName);
    };
  }
}
class LoggingEventDispatcher extends EventDispatcher {
  List log;
  LoggingEventDispatcher() : super() {
    /* super call moved to initializer */;
    this.log = [];
  }
  dispatchEvent(
      num elementIndex, String eventName, Map<String, dynamic> locals) {
    ListWrapper.push(this.log, [elementIndex, eventName, locals]);
  }
}
class FakeEvent {
  var target;
  FakeEvent(target) {
    this.target = target;
  }
}
