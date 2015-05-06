library angular2.src.core.compiler.view_manager;

import "package:angular2/di.dart" show Injector, Binding;
import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, StringMapWrapper, List;
import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, BaseException;
import "view.dart" as viewModule;
import "element_ref.dart" show ElementRef;
import "view_ref.dart"
    show ProtoViewRef, ViewRef, internalView, internalProtoView;
import "view_container_ref.dart" show ViewContainerRef;
import "package:angular2/src/render/api.dart"
    show Renderer, RenderViewRef, RenderViewContainerRef;
import "view_manager_utils.dart" show AppViewManagerUtils;
import "view_pool.dart"
    show
        AppViewPool; /**
 * Entry point for creating, moving views in the view hierarchy and destroying views.
 * This manager contains all recursion and delegates to helper methods
 * in AppViewManagerUtils and the Renderer, so unit tests get simpler.
 */

@Injectable()
class AppViewManager {
  AppViewPool _viewPool;
  AppViewManagerUtils _utils;
  Renderer _renderer;
  AppViewManager(
      AppViewPool viewPool, AppViewManagerUtils utils, Renderer renderer) {
    this._renderer = renderer;
    this._viewPool = viewPool;
    this._utils = utils;
  }
  ViewContainerRef getViewContainer(ElementRef location) {
    var hostView = internalView(location.parentView);
    return hostView.elementInjectors[location.boundElementIndex]
        .getViewContainerRef();
  }
  dynamic getComponent(ElementRef hostLocation) {
    var hostView = internalView(hostLocation.parentView);
    var boundElementIndex = hostLocation.boundElementIndex;
    return this._utils.getComponentInstance(hostView, boundElementIndex);
  }
  ViewRef createDynamicComponentView(ElementRef hostLocation,
      ProtoViewRef componentProtoViewRef, Binding componentBinding,
      Injector injector) {
    var componentProtoView = internalProtoView(componentProtoViewRef);
    var hostView = internalView(hostLocation.parentView);
    var boundElementIndex = hostLocation.boundElementIndex;
    var binder = hostView.proto.elementBinders[boundElementIndex];
    if (!binder.hasDynamicComponent()) {
      throw new BaseException(
          '''There is no dynamic component directive at element ${ boundElementIndex}''');
    }
    var componentView = this._createViewRecurse(componentProtoView);
    var renderViewRefs = this._renderer.createDynamicComponentView(
        hostView.render, boundElementIndex, componentProtoView.render);
    componentView.render = renderViewRefs[0];
    this._utils.attachComponentView(hostView, boundElementIndex, componentView);
    this._utils.hydrateDynamicComponentInElementInjector(
        hostView, boundElementIndex, componentBinding, injector);
    this._utils.hydrateComponentView(hostView, boundElementIndex);
    this._viewHydrateRecurse(componentView, renderViewRefs, 1);
    return new ViewRef(componentView);
  }
  ViewRef createInPlaceHostView(ElementRef parentComponentLocation,
      hostElementSelector, ProtoViewRef hostProtoViewRef, Injector injector) {
    var hostProtoView = internalProtoView(hostProtoViewRef);
    var parentComponentHostView = null;
    var parentComponentBoundElementIndex = null;
    var parentRenderViewRef = null;
    if (isPresent(parentComponentLocation)) {
      parentComponentHostView =
          internalView(parentComponentLocation.parentView);
      parentComponentBoundElementIndex =
          parentComponentLocation.boundElementIndex;
      parentRenderViewRef = parentComponentHostView.componentChildViews[
          parentComponentBoundElementIndex].render;
    }
    var hostView = this._createViewRecurse(hostProtoView);
    var renderViewRefs = this._renderer.createInPlaceHostView(
        parentRenderViewRef, hostElementSelector, hostProtoView.render);
    hostView.render = renderViewRefs[0];
    this._utils.attachAndHydrateInPlaceHostView(parentComponentHostView,
        parentComponentBoundElementIndex, hostView, injector);
    this._viewHydrateRecurse(hostView, renderViewRefs, 1);
    return new ViewRef(hostView);
  }
  destroyInPlaceHostView(
      ElementRef parentComponentLocation, ViewRef hostViewRef) {
    var hostView = internalView(hostViewRef);
    var parentView = null;
    var parentRenderViewRef = null;
    if (isPresent(parentComponentLocation)) {
      parentView =
          internalView(parentComponentLocation.parentView).componentChildViews[
          parentComponentLocation.boundElementIndex];
      parentRenderViewRef = parentView.render;
    }
    var hostViewRenderRef = hostView.render;
    this._viewDehydrateRecurse(hostView);
    this._utils.detachInPlaceHostView(parentView, hostView);
    this._renderer.destroyInPlaceHostView(
        parentRenderViewRef, hostViewRenderRef);
    this._destroyView(hostView);
  }
  ViewRef createViewInContainer(
      ElementRef viewContainerLocation, num atIndex, ProtoViewRef protoViewRef,
      [Injector injector = null]) {
    var protoView = internalProtoView(protoViewRef);
    var parentView = internalView(viewContainerLocation.parentView);
    var boundElementIndex = viewContainerLocation.boundElementIndex;
    var view = this._createViewRecurse(protoView);
    var renderViewRefs = this._renderer.createViewInContainer(
        this._getRenderViewContainerRef(parentView, boundElementIndex), atIndex,
        view.proto.render);
    view.render = renderViewRefs[0];
    this._utils.attachViewInContainer(
        parentView, boundElementIndex, atIndex, view);
    this._utils.hydrateViewInContainer(
        parentView, boundElementIndex, atIndex, injector);
    this._viewHydrateRecurse(view, renderViewRefs, 1);
    return new ViewRef(view);
  }
  destroyViewInContainer(ElementRef viewContainerLocation, num atIndex) {
    var parentView = internalView(viewContainerLocation.parentView);
    var boundElementIndex = viewContainerLocation.boundElementIndex;
    var viewContainer = parentView.viewContainers[boundElementIndex];
    var view = viewContainer.views[atIndex];
    this._viewDehydrateRecurse(view);
    this._utils.detachViewInContainer(parentView, boundElementIndex, atIndex);
    this._renderer.destroyViewInContainer(
        this._getRenderViewContainerRef(parentView, boundElementIndex),
        atIndex);
    this._destroyView(view);
  }
  ViewRef attachViewInContainer(
      ElementRef viewContainerLocation, num atIndex, ViewRef viewRef) {
    var view = internalView(viewRef);
    var parentView = internalView(viewContainerLocation.parentView);
    var boundElementIndex = viewContainerLocation.boundElementIndex;
    this._utils.attachViewInContainer(
        parentView, boundElementIndex, atIndex, view);
    this._renderer.insertViewIntoContainer(
        this._getRenderViewContainerRef(parentView, boundElementIndex), atIndex,
        view.render);
    return viewRef;
  }
  ViewRef detachViewInContainer(ElementRef viewContainerLocation, num atIndex) {
    var parentView = internalView(viewContainerLocation.parentView);
    var boundElementIndex = viewContainerLocation.boundElementIndex;
    var viewContainer = parentView.viewContainers[boundElementIndex];
    var view = viewContainer.views[atIndex];
    this._utils.detachViewInContainer(parentView, boundElementIndex, atIndex);
    this._renderer.detachViewFromContainer(
        this._getRenderViewContainerRef(parentView, boundElementIndex),
        atIndex);
    return new ViewRef(view);
  }
  _getRenderViewContainerRef(
      viewModule.AppView parentView, num boundElementIndex) {
    return new RenderViewContainerRef(parentView.render, boundElementIndex);
  }
  _createViewRecurse(viewModule.AppProtoView protoView) {
    var view = this._viewPool.getView(protoView);
    if (isBlank(view)) {
      view = this._utils.createView(protoView, this, this._renderer);
      var binders = protoView.elementBinders;
      for (var binderIdx = 0; binderIdx < binders.length; binderIdx++) {
        var binder = binders[binderIdx];
        if (binder.hasStaticComponent()) {
          var childView = this._createViewRecurse(binder.nestedProtoView);
          this._utils.attachComponentView(view, binderIdx, childView);
        }
      }
    }
    return view;
  }
  _destroyView(viewModule.AppView view) {
    this._viewPool.returnView(view);
  }
  num _viewHydrateRecurse(viewModule.AppView view,
      List<RenderViewRef> renderComponentViewRefs, num renderComponentIndex) {
    this._renderer.setEventDispatcher(view.render, view);
    var binders = view.proto.elementBinders;
    for (var i = 0; i < binders.length; ++i) {
      if (binders[i].hasStaticComponent()) {
        var childView = view.componentChildViews[i];
        childView.render = renderComponentViewRefs[renderComponentIndex++];
        this._utils.hydrateComponentView(view, i);
        renderComponentIndex = this._viewHydrateRecurse(
            view.componentChildViews[i], renderComponentViewRefs,
            renderComponentIndex);
      }
    }
    return renderComponentIndex;
  }
  _viewDehydrateRecurse(viewModule.AppView view) {
    this._utils.dehydrateView(view);
    var binders = view.proto.elementBinders;
    for (var i = 0; i < binders.length; i++) {
      var componentView = view.componentChildViews[i];
      if (isPresent(componentView)) {
        this._viewDehydrateRecurse(componentView);
        if (binders[i].hasDynamicComponent()) {
          this._utils.detachComponentView(view, i);
          this._destroyView(componentView);
        }
      }
      var vc = view.viewContainers[i];
      if (isPresent(vc)) {
        for (var j = vc.views.length - 1; j >= 0; j--) {
          var childView = vc.views[j];
          this._viewDehydrateRecurse(childView);
          this._utils.detachViewInContainer(view, i, j);
          this._destroyView(childView);
        }
      }
    } // imperativeHostViews
    for (var i = 0; i < view.imperativeHostViews.length; i++) {
      var hostView = view.imperativeHostViews[i];
      this._viewDehydrateRecurse(hostView);
      this._utils.detachInPlaceHostView(view, hostView);
      this._destroyView(hostView);
    }
    view.render = null;
  }
}
