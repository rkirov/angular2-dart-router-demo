library angular2.src.render.dom.direct_dom_renderer;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/facade/lang.dart"
    show isBlank, isPresent, BaseException;
import "../api.dart" as api;
import "view/view.dart" show RenderView;
import "view/proto_view.dart" show RenderProtoView;
import "view/view_factory.dart" show ViewFactory;
import "view/view_hydrator.dart" show RenderViewHydrator;
import "compiler/compiler.dart" show Compiler;
import "shadow_dom/shadow_dom_strategy.dart" show ShadowDomStrategy;
import "view/proto_view_builder.dart" show ProtoViewBuilder;
import "view/view_container.dart" show ViewContainer;

_resolveViewContainer(api.RenderViewContainerRef vc) {
  return _resolveView(vc.view).getOrCreateViewContainer(vc.elementIndex);
}
_resolveView(DirectDomViewRef viewRef) {
  return isPresent(viewRef) ? viewRef.delegate : null;
}
_resolveProtoView(DirectDomProtoViewRef protoViewRef) {
  return isPresent(protoViewRef) ? protoViewRef.delegate : null;
}
_wrapView(RenderView view) {
  return new DirectDomViewRef(view);
}
_collectComponentChildViewRefs(view, [target = null]) {
  if (isBlank(target)) {
    target = [];
  }
  ListWrapper.push(target, _wrapView(view));
  ListWrapper.forEach(view.componentChildViews, (view) {
    if (isPresent(view)) {
      _collectComponentChildViewRefs(view, target);
    }
  });
  return target;
} // public so that the compiler can use it.
class DirectDomProtoViewRef extends api.RenderProtoViewRef {
  RenderProtoView delegate;
  DirectDomProtoViewRef(RenderProtoView delegate) : super() {
    /* super call moved to initializer */;
    this.delegate = delegate;
  }
}
class DirectDomViewRef extends api.RenderViewRef {
  RenderView delegate;
  DirectDomViewRef(RenderView delegate) : super() {
    /* super call moved to initializer */;
    this.delegate = delegate;
  }
}
@Injectable()
class DirectDomRenderer extends api.Renderer {
  Compiler _compiler;
  ViewFactory _viewFactory;
  RenderViewHydrator _viewHydrator;
  ShadowDomStrategy _shadowDomStrategy;
  DirectDomRenderer(Compiler compiler, ViewFactory viewFactory,
      RenderViewHydrator viewHydrator, ShadowDomStrategy shadowDomStrategy)
      : super() {
    /* super call moved to initializer */;
    this._compiler = compiler;
    this._viewFactory = viewFactory;
    this._viewHydrator = viewHydrator;
    this._shadowDomStrategy = shadowDomStrategy;
  }
  Future<api.ProtoViewDto> createHostProtoView(
      api.DirectiveMetadata directiveMetadata) {
    return this._compiler.compileHost(directiveMetadata);
  }
  Future<api.ProtoViewDto> createImperativeComponentProtoView(rendererId) {
    var protoViewBuilder = new ProtoViewBuilder(null);
    protoViewBuilder.setImperativeRendererId(rendererId);
    return PromiseWrapper.resolve(protoViewBuilder.build());
  }
  Future<api.ProtoViewDto> compile(api.ViewDefinition view) {
    // Note: compiler already uses a DirectDomProtoViewRef, so we don't
    // need to do anything here
    return this._compiler.compile(view);
  }
  mergeChildComponentProtoViews(api.RenderProtoViewRef protoViewRef,
      List<api.RenderProtoViewRef> protoViewRefs) {
    _resolveProtoView(protoViewRef).mergeChildComponentProtoViews(
        ListWrapper.map(protoViewRefs, _resolveProtoView));
  }
  List<api.RenderViewRef> createViewInContainer(
      api.RenderViewContainerRef vcRef, num atIndex,
      api.RenderProtoViewRef protoViewRef) {
    var view = this._viewFactory.getView(_resolveProtoView(protoViewRef));
    var vc = _resolveViewContainer(vcRef);
    this._viewHydrator.hydrateViewInViewContainer(vc, view);
    vc.insert(view, atIndex);
    return _collectComponentChildViewRefs(view);
  }
  void destroyViewInContainer(api.RenderViewContainerRef vcRef, num atIndex) {
    var vc = _resolveViewContainer(vcRef);
    var view = vc.detach(atIndex);
    this._viewHydrator.dehydrateViewInViewContainer(vc, view);
    this._viewFactory.returnView(view);
  }
  void insertViewIntoContainer(api.RenderViewContainerRef vcRef,
      [atIndex = -1, api.RenderViewRef viewRef]) {
    _resolveViewContainer(vcRef).insert(_resolveView(viewRef), atIndex);
  }
  void detachViewFromContainer(api.RenderViewContainerRef vcRef, num atIndex) {
    _resolveViewContainer(vcRef).detach(atIndex);
  }
  List<api.RenderViewRef> createDynamicComponentView(
      api.RenderViewRef hostViewRef, num elementIndex,
      api.RenderProtoViewRef componentViewRef) {
    var hostView = _resolveView(hostViewRef);
    var componentView =
        this._viewFactory.getView(_resolveProtoView(componentViewRef));
    this._viewHydrator.hydrateDynamicComponentView(
        hostView, elementIndex, componentView);
    return _collectComponentChildViewRefs(componentView);
  }
  void destroyDynamicComponentView(
      api.RenderViewRef hostViewRef, num elementIndex) {
    throw new BaseException("Not supported yet");
  }
  List<api.RenderViewRef> createInPlaceHostView(api.RenderViewRef parentViewRef,
      hostElementSelector, api.RenderProtoViewRef hostProtoViewRef) {
    var parentView = _resolveView(parentViewRef);
    var hostView = this._viewFactory.createInPlaceHostView(
        hostElementSelector, _resolveProtoView(hostProtoViewRef));
    this._viewHydrator.hydrateInPlaceHostView(parentView, hostView);
    return _collectComponentChildViewRefs(hostView);
  } /**
   * Destroys the given host view in the given parent view.
   */
  void destroyInPlaceHostView(
      api.RenderViewRef parentViewRef, api.RenderViewRef hostViewRef) {
    var parentView = _resolveView(parentViewRef);
    var hostView = _resolveView(hostViewRef);
    this._viewHydrator.dehydrateInPlaceHostView(parentView, hostView);
  }
  void setImperativeComponentRootNodes(
      api.RenderViewRef parentViewRef, num elementIndex, List nodes) {
    var parentView = _resolveView(parentViewRef);
    var hostElement = parentView.boundElements[elementIndex];
    var componentView = parentView.componentChildViews[elementIndex];
    if (isBlank(componentView)) {
      throw new BaseException(
          '''There is no componentChildView at index ${ elementIndex}''');
    }
    if (isBlank(componentView.proto.imperativeRendererId)) {
      throw new BaseException(
          '''This component view has no imperative renderer''');
    }
    ViewContainer.removeViewNodes(componentView);
    componentView.rootNodes = nodes;
    this._shadowDomStrategy.attachTemplate(hostElement, componentView);
  }
  void setElementProperty(api.RenderViewRef viewRef, num elementIndex,
      String propertyName, dynamic propertyValue) {
    _resolveView(viewRef).setElementProperty(
        elementIndex, propertyName, propertyValue);
  }
  void setText(api.RenderViewRef viewRef, num textNodeIndex, String text) {
    _resolveView(viewRef).setText(textNodeIndex, text);
  }
  void setEventDispatcher(api.RenderViewRef viewRef, dynamic dispatcher) {
    _resolveView(viewRef).setEventDispatcher(dispatcher);
  }
}
