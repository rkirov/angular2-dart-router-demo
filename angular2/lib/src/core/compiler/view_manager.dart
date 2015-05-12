library angular2.src.core.compiler.view_manager;

import "package:angular2/di.dart" show Injector, Binding;
import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, BaseException;
import "view.dart" as viewModule;
import "element_ref.dart" show ElementRef;
import "view_ref.dart"
    show ProtoViewRef, ViewRef, internalView, internalProtoView;
import "view_container_ref.dart" show ViewContainerRef;
import "package:angular2/src/render/api.dart" show Renderer, RenderViewRef;
import "view_manager_utils.dart" show AppViewManagerUtils;
import "view_pool.dart" show AppViewPool;

/**
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
  ViewRef getComponentView(ElementRef hostLocation) {
    var hostView = internalView(hostLocation.parentView);
    var boundElementIndex = hostLocation.boundElementIndex;
    return new ViewRef(hostView.componentChildViews[boundElementIndex]);
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
    var componentView = this._createPooledView(componentProtoView);
    this._renderer.attachComponentView(
        hostView.render, boundElementIndex, componentView.render);
    this._utils.attachComponentView(hostView, boundElementIndex, componentView);
    this._utils.hydrateDynamicComponentInElementInjector(
        hostView, boundElementIndex, componentBinding, injector);
    this._utils.hydrateComponentView(hostView, boundElementIndex);
    this._viewHydrateRecurse(componentView);
    return new ViewRef(componentView);
  }
  ViewRef createInPlaceHostView(ElementRef parentComponentLocation,
      String hostElementSelector, ProtoViewRef hostProtoViewRef,
      Injector injector) {
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
    var hostRenderView = this._renderer.createInPlaceHostView(
        parentRenderViewRef, hostElementSelector, hostProtoView.render);
    var hostView = this._utils.createView(
        hostProtoView, hostRenderView, this, this._renderer);
    this._renderer.setEventDispatcher(hostView.render, hostView);
    this._createViewRecurse(hostView);
    this._utils.attachAndHydrateInPlaceHostView(parentComponentHostView,
        parentComponentBoundElementIndex, hostView, injector);
    this._viewHydrateRecurse(hostView);
    return new ViewRef(hostView);
  }
  destroyInPlaceHostView(
      ElementRef parentComponentLocation, ViewRef hostViewRef) {
    var hostView = internalView(hostViewRef);
    var parentView = null;
    if (isPresent(parentComponentLocation)) {
      parentView =
          internalView(parentComponentLocation.parentView).componentChildViews[
          parentComponentLocation.boundElementIndex];
    }
    this._destroyInPlaceHostView(parentView, hostView);
  }
  ViewRef createViewInContainer(
      ElementRef viewContainerLocation, num atIndex, ProtoViewRef protoViewRef,
      [ElementRef context = null, Injector injector = null]) {
    var protoView = internalProtoView(protoViewRef);
    var parentView = internalView(viewContainerLocation.parentView);
    var boundElementIndex = viewContainerLocation.boundElementIndex;
    var contextView = null;
    var contextBoundElementIndex = null;
    if (isPresent(context)) {
      contextView = internalView(context.parentView);
      contextBoundElementIndex = context.boundElementIndex;
    }
    var view = this._createPooledView(protoView);
    this._renderer.attachViewInContainer(
        parentView.render, boundElementIndex, atIndex, view.render);
    this._utils.attachViewInContainer(parentView, boundElementIndex,
        contextView, contextBoundElementIndex, atIndex, view);
    this._utils.hydrateViewInContainer(parentView, boundElementIndex,
        contextView, contextBoundElementIndex, atIndex, injector);
    this._viewHydrateRecurse(view);
    return new ViewRef(view);
  }
  destroyViewInContainer(ElementRef viewContainerLocation, num atIndex) {
    var parentView = internalView(viewContainerLocation.parentView);
    var boundElementIndex = viewContainerLocation.boundElementIndex;
    this._destroyViewInContainer(parentView, boundElementIndex, atIndex);
  }
  ViewRef attachViewInContainer(
      ElementRef viewContainerLocation, num atIndex, ViewRef viewRef) {
    var view = internalView(viewRef);
    var parentView = internalView(viewContainerLocation.parentView);
    var boundElementIndex = viewContainerLocation.boundElementIndex;
    // TODO(tbosch): the public methods attachViewInContainer/detachViewInContainer

    // are used for moving elements without the same container.

    // We will change this into an atomic `move` operation, which should preserve the

    // previous parent injector (see https://github.com/angular/angular/issues/1377).

    // Right now we are destroying any special

    // context view that might have been used.
    this._utils.attachViewInContainer(
        parentView, boundElementIndex, null, null, atIndex, view);
    this._renderer.attachViewInContainer(
        parentView.render, boundElementIndex, atIndex, view.render);
    return viewRef;
  }
  ViewRef detachViewInContainer(ElementRef viewContainerLocation, num atIndex) {
    var parentView = internalView(viewContainerLocation.parentView);
    var boundElementIndex = viewContainerLocation.boundElementIndex;
    var viewContainer = parentView.viewContainers[boundElementIndex];
    var view = viewContainer.views[atIndex];
    this._utils.detachViewInContainer(parentView, boundElementIndex, atIndex);
    this._renderer.detachViewInContainer(
        parentView.render, boundElementIndex, atIndex, view.render);
    return new ViewRef(view);
  }
  viewModule.AppView _createPooledView(viewModule.AppProtoView protoView) {
    var view = this._viewPool.getView(protoView);
    if (isBlank(view)) {
      view = this._utils.createView(protoView,
          this._renderer.createView(protoView.render), this, this._renderer);
      this._renderer.setEventDispatcher(view.render, view);
      this._createViewRecurse(view);
    }
    return view;
  }
  _createViewRecurse(viewModule.AppView view) {
    var binders = view.proto.elementBinders;
    for (var binderIdx = 0; binderIdx < binders.length; binderIdx++) {
      var binder = binders[binderIdx];
      if (binder.hasStaticComponent()) {
        var childView = this._createPooledView(binder.nestedProtoView);
        this._renderer.attachComponentView(
            view.render, binderIdx, childView.render);
        this._utils.attachComponentView(view, binderIdx, childView);
      }
    }
  }
  _destroyPooledView(viewModule.AppView view) {
    // TODO: if the pool is full, call renderer.destroyView as well!
    this._viewPool.returnView(view);
  }
  _destroyViewInContainer(parentView, boundElementIndex, num atIndex) {
    var viewContainer = parentView.viewContainers[boundElementIndex];
    var view = viewContainer.views[atIndex];
    this._viewDehydrateRecurse(view, false);
    this._utils.detachViewInContainer(parentView, boundElementIndex, atIndex);
    this._renderer.detachViewInContainer(
        parentView.render, boundElementIndex, atIndex, view.render);
    this._destroyPooledView(view);
  }
  _destroyComponentView(hostView, boundElementIndex, componentView) {
    this._viewDehydrateRecurse(componentView, false);
    this._renderer.detachComponentView(
        hostView.render, boundElementIndex, componentView.render);
    this._utils.detachComponentView(hostView, boundElementIndex);
    this._destroyPooledView(componentView);
  }
  _destroyInPlaceHostView(parentView, hostView) {
    var parentRenderViewRef = null;
    if (isPresent(parentView)) {
      parentRenderViewRef = parentView.render;
    }
    this._viewDehydrateRecurse(hostView, true);
    this._utils.detachInPlaceHostView(parentView, hostView);
    this._renderer.destroyInPlaceHostView(parentRenderViewRef, hostView.render);
  }
  _viewHydrateRecurse(viewModule.AppView view) {
    this._renderer.hydrateView(view.render);
    var binders = view.proto.elementBinders;
    for (var i = 0; i < binders.length; ++i) {
      if (binders[i].hasStaticComponent()) {
        this._utils.hydrateComponentView(view, i);
        this._viewHydrateRecurse(view.componentChildViews[i]);
      }
    }
  }
  _viewDehydrateRecurse(viewModule.AppView view, forceDestroyComponents) {
    this._utils.dehydrateView(view);
    this._renderer.dehydrateView(view.render);
    var binders = view.proto.elementBinders;
    for (var i = 0; i < binders.length; i++) {
      var componentView = view.componentChildViews[i];
      if (isPresent(componentView)) {
        if (binders[i].hasDynamicComponent() || forceDestroyComponents) {
          this._destroyComponentView(view, i, componentView);
        } else {
          this._viewDehydrateRecurse(componentView, false);
        }
      }
      var vc = view.viewContainers[i];
      if (isPresent(vc)) {
        for (var j = vc.views.length - 1; j >= 0; j--) {
          this._destroyViewInContainer(view, i, j);
        }
      }
    }
    // inPlaceHostViews
    for (var i = view.inPlaceHostViews.length - 1; i >= 0; i--) {
      var hostView = view.inPlaceHostViews[i];
      this._destroyInPlaceHostView(view, hostView);
    }
  }
}
