library angular2.src.render.dom.view.view_hydrator;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/lang.dart"
    show int, isPresent, isBlank, BaseException;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, StringMapWrapper, List;
import "../shadow_dom/light_dom.dart" as ldModule;
import "../events/event_manager.dart" show EventManager;
import "view_factory.dart" show ViewFactory;
import "view_container.dart" as vcModule;
import "view.dart" as viewModule;
import "../shadow_dom/shadow_dom_strategy.dart"
    show
        ShadowDomStrategy; /**
 * A dehydrated view is a state of the view that allows it to be moved around
 * the view tree.
 *
 * A dehydrated view has the following properties:
 *
 * - all viewcontainers are empty.
 *
 * A call to hydrate/dehydrate is called whenever a view is attached/detached,
 * but it does not do the attach/detach itself.
 */

@Injectable()
class RenderViewHydrator {
  EventManager _eventManager;
  ViewFactory _viewFactory;
  ShadowDomStrategy _shadowDomStrategy;
  RenderViewHydrator(EventManager eventManager, ViewFactory viewFactory,
      ShadowDomStrategy shadowDomStrategy) {
    this._eventManager = eventManager;
    this._viewFactory = viewFactory;
    this._shadowDomStrategy = shadowDomStrategy;
  }
  hydrateDynamicComponentView(viewModule.RenderView hostView,
      num boundElementIndex, viewModule.RenderView componentView) {
    ViewFactory.setComponentView(
        this._shadowDomStrategy, hostView, boundElementIndex, componentView);
    var lightDom = hostView.lightDoms[boundElementIndex];
    this._viewHydrateRecurse(componentView, lightDom);
    if (isPresent(lightDom)) {
      lightDom.redistribute();
    }
  }
  dehydrateDynamicComponentView(
      viewModule.RenderView parentView, num boundElementIndex) {
    throw new BaseException("Not supported yet");
  }
  hydrateInPlaceHostView(
      viewModule.RenderView parentView, viewModule.RenderView hostView) {
    if (isPresent(parentView)) {
      ListWrapper.push(parentView.imperativeHostViews, hostView);
    }
    this._viewHydrateRecurse(hostView, null);
  }
  dehydrateInPlaceHostView(
      viewModule.RenderView parentView, viewModule.RenderView hostView) {
    if (isPresent(parentView)) {
      ListWrapper.remove(parentView.imperativeHostViews, hostView);
    }
    vcModule.ViewContainer.removeViewNodes(hostView);
    hostView.rootNodes = [];
    this._viewDehydrateRecurse(hostView);
  }
  hydrateViewInViewContainer(
      vcModule.ViewContainer viewContainer, viewModule.RenderView view) {
    this._viewHydrateRecurse(view, viewContainer.parentView.hostLightDom);
  }
  dehydrateViewInViewContainer(
      vcModule.ViewContainer viewContainer, viewModule.RenderView view) {
    this._viewDehydrateRecurse(view);
  }
  _viewHydrateRecurse(view, ldModule.LightDom hostLightDom) {
    if (view.hydrated) throw new BaseException("The view is already hydrated.");
    view.hydrated = true;
    view.hostLightDom = hostLightDom; // content tags
    for (var i = 0; i < view.contentTags.length; i++) {
      var destLightDom = view.getDirectParentLightDom(i);
      var ct = view.contentTags[i];
      if (isPresent(ct)) {
        ct.hydrate(destLightDom);
      }
    } // componentChildViews
    for (var i = 0; i < view.componentChildViews.length; i++) {
      var cv = view.componentChildViews[i];
      if (isPresent(cv)) {
        this._viewHydrateRecurse(cv, view.lightDoms[i]);
      }
    }
    for (var i = 0; i < view.lightDoms.length; ++i) {
      var lightDom = view.lightDoms[i];
      if (isPresent(lightDom)) {
        lightDom.redistribute();
      }
    } //add global events
    view.eventHandlerRemovers = ListWrapper.create();
    var binders = view.proto.elementBinders;
    for (var binderIdx = 0; binderIdx < binders.length; binderIdx++) {
      var binder = binders[binderIdx];
      if (isPresent(binder.globalEvents)) {
        for (var i = 0; i < binder.globalEvents.length; i++) {
          var globalEvent = binder.globalEvents[i];
          var remover = this._createGlobalEventListener(view, binderIdx,
              globalEvent.name, globalEvent.target, globalEvent.fullName);
          ListWrapper.push(view.eventHandlerRemovers, remover);
        }
      }
    }
  }
  Function _createGlobalEventListener(
      view, elementIndex, eventName, eventTarget, fullName) {
    return this._eventManager.addGlobalEventListener(eventTarget, eventName,
        (event) {
      view.dispatchEvent(elementIndex, fullName, event);
    });
  }
  _viewDehydrateRecurse(view) {
    // Note: preserve the opposite order of the hydration process.
    // componentChildViews
    for (var i = 0; i < view.componentChildViews.length; i++) {
      var cv = view.componentChildViews[i];
      if (isPresent(cv)) {
        this._viewDehydrateRecurse(cv);
        if (view.proto.elementBinders[i].hasDynamicComponent()) {
          vcModule.ViewContainer.removeViewNodes(cv);
          this._viewFactory.returnView(cv);
          view.lightDoms[i] = null;
          view.componentChildViews[i] = null;
        }
      }
    } // imperativeHostViews
    for (var i = 0; i < view.imperativeHostViews.length; i++) {
      var hostView = view.imperativeHostViews[i];
      this._viewDehydrateRecurse(hostView);
      vcModule.ViewContainer.removeViewNodes(hostView);
      hostView.rootNodes = [];
      this._viewFactory.returnView(hostView);
    }
    view.imperativeHostViews = []; // viewContainers and content tags
    if (isPresent(view.viewContainers)) {
      for (var i = 0; i < view.viewContainers.length; i++) {
        var vc = view.viewContainers[i];
        if (isPresent(vc)) {
          this._viewContainerDehydrateRecurse(vc);
        }
        var ct = view.contentTags[i];
        if (isPresent(ct)) {
          ct.dehydrate();
        }
      }
    } //remove global events
    for (var i = 0; i < view.eventHandlerRemovers.length; i++) {
      view.eventHandlerRemovers[i]();
    }
    view.hostLightDom = null;
    view.eventHandlerRemovers = null;
    view.setEventDispatcher(null);
    view.hydrated = false;
  }
  _viewContainerDehydrateRecurse(viewContainer) {
    for (var i = 0; i < viewContainer.views.length; i++) {
      var view = viewContainer.views[i];
      this._viewDehydrateRecurse(view);
      this._viewFactory.returnView(view);
    }
    viewContainer.clear();
  }
}
