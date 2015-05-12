library angular2.test.render.dom.dom_testbed;

import "package:angular2/src/di/annotations_impl.dart" show Inject, Injectable;
import "package:angular2/src/facade/collection.dart"
    show MapWrapper, ListWrapper, List, Map;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/render/dom/dom_renderer.dart"
    show DomRenderer, DOCUMENT_TOKEN;
import "package:angular2/src/render/dom/compiler/compiler.dart"
    show DefaultDomCompiler;
import "package:angular2/src/render/dom/view/view.dart" show DomView;
import "package:angular2/src/render/api.dart"
    show
        RenderViewRef,
        ProtoViewDto,
        ViewDefinition,
        EventDispatcher,
        DirectiveMetadata;
import "package:angular2/src/render/dom/view/view.dart"
    show resolveInternalDomView;
import "package:angular2/test_lib.dart" show el, dispatchEvent;

class TestView extends EventDispatcher {
  DomView rawView;
  RenderViewRef viewRef;
  List events;
  TestView(RenderViewRef viewRef) : super() {
    /* super call moved to initializer */;
    this.viewRef = viewRef;
    this.rawView = resolveInternalDomView(viewRef);
    this.events = [];
  }
}
class LoggingEventDispatcher extends EventDispatcher {
  List log;
  LoggingEventDispatcher(List log) : super() {
    /* super call moved to initializer */;
    this.log = log;
  }
  dispatchEvent(
      num elementIndex, String eventName, Map<String, dynamic> locals) {
    ListWrapper.push(this.log, [elementIndex, eventName, locals]);
    return true;
  }
}
@Injectable()
class DomTestbed {
  DomRenderer renderer;
  DefaultDomCompiler compiler;
  var rootEl;
  DomTestbed(DomRenderer renderer, DefaultDomCompiler compiler,
      @Inject(DOCUMENT_TOKEN) document) {
    this.renderer = renderer;
    this.compiler = compiler;
    this.rootEl = el("<div id=\"root\"></div>");
    var oldRoots = DOM.querySelectorAll(document, "#root");
    for (var i = 0; i < oldRoots.length; i++) {
      DOM.remove(oldRoots[i]);
    }
    DOM.appendChild(DOM.querySelector(document, "body"), this.rootEl);
  }
  Future<List<ProtoViewDto>> compileAll(List directivesOrViewDefinitions) {
    return PromiseWrapper.all(ListWrapper.map(directivesOrViewDefinitions,
        (entry) {
      if (entry is DirectiveMetadata) {
        return this.compiler.compileHost(entry);
      } else {
        return this.compiler.compile(entry);
      }
    }));
  }
  _createTestView(RenderViewRef viewRef) {
    var testView = new TestView(viewRef);
    this.renderer.setEventDispatcher(
        viewRef, new LoggingEventDispatcher(testView.events));
    return testView;
  }
  TestView createRootView(ProtoViewDto rootProtoView) {
    var viewRef = this.renderer.createInPlaceHostView(
        null, "#root", rootProtoView.render);
    this.renderer.hydrateView(viewRef);
    return this._createTestView(viewRef);
  }
  TestView createComponentView(RenderViewRef parentViewRef,
      num boundElementIndex, ProtoViewDto componentProtoView) {
    var componentViewRef = this.renderer.createView(componentProtoView.render);
    this.renderer.attachComponentView(
        parentViewRef, boundElementIndex, componentViewRef);
    this.renderer.hydrateView(componentViewRef);
    return this._createTestView(componentViewRef);
  }
  List<TestView> createRootViews(List<ProtoViewDto> protoViews) {
    var views = [];
    var lastView = this.createRootView(protoViews[0]);
    ListWrapper.push(views, lastView);
    for (var i = 1; i < protoViews.length; i++) {
      lastView = this.createComponentView(lastView.viewRef, 0, protoViews[i]);
      ListWrapper.push(views, lastView);
    }
    return views;
  }
  destroyComponentView(RenderViewRef parentViewRef, num boundElementIndex,
      RenderViewRef componentView) {
    this.renderer.dehydrateView(componentView);
    this.renderer.detachComponentView(
        parentViewRef, boundElementIndex, componentView);
  }
  TestView createViewInContainer(RenderViewRef parentViewRef,
      num boundElementIndex, num atIndex, ProtoViewDto protoView) {
    var viewRef = this.renderer.createView(protoView.render);
    this.renderer.attachViewInContainer(
        parentViewRef, boundElementIndex, atIndex, viewRef);
    this.renderer.hydrateView(viewRef);
    return this._createTestView(viewRef);
  }
  destroyViewInContainer(RenderViewRef parentViewRef, num boundElementIndex,
      num atIndex, RenderViewRef viewRef) {
    this.renderer.dehydrateView(viewRef);
    this.renderer.detachViewInContainer(
        parentViewRef, boundElementIndex, atIndex, viewRef);
    this.renderer.destroyView(viewRef);
  }
  triggerEvent(RenderViewRef viewRef, num boundElementIndex, String eventName) {
    var element =
        resolveInternalDomView(viewRef).boundElements[boundElementIndex];
    dispatchEvent(element, eventName);
  }
}
