library angular2.src.core.compiler.view_manager_utils;

import "package:angular2/di.dart" show Injector, Binding;
import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, StringMapWrapper, List;
import "element_injector.dart" as eli;
import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, BaseException;
import "view.dart" as viewModule;
import "view_manager.dart" as avmModule;
import "package:angular2/src/render/api.dart" show Renderer;
import "package:angular2/change_detection.dart"
    show BindingPropagationConfig, Locals;
import "directive_metadata_reader.dart" show DirectiveMetadataReader;
import "package:angular2/src/render/api.dart" show RenderViewRef;

@Injectable()
class AppViewManagerUtils {
  DirectiveMetadataReader _metadataReader;
  AppViewManagerUtils(DirectiveMetadataReader metadataReader) {
    this._metadataReader = metadataReader;
  }
  dynamic getComponentInstance(
      viewModule.AppView parentView, num boundElementIndex) {
    var binder = parentView.proto.elementBinders[boundElementIndex];
    var eli = parentView.elementInjectors[boundElementIndex];
    if (binder.hasDynamicComponent()) {
      return eli.getDynamicallyLoadedComponent();
    } else {
      return eli.getComponent();
    }
  }
  viewModule.AppView createView(viewModule.AppProtoView protoView,
      RenderViewRef renderView, avmModule.AppViewManager viewManager,
      Renderer renderer) {
    var view =
        new viewModule.AppView(renderer, protoView, protoView.protoLocals);
    // TODO(tbosch): pass RenderViewRef as argument to AppView!
    view.render = renderView;
    var changeDetector = protoView.protoChangeDetector.instantiate(view);
    var binders = protoView.elementBinders;
    var elementInjectors = ListWrapper.createFixedSize(binders.length);
    var rootElementInjectors = [];
    var preBuiltObjects = ListWrapper.createFixedSize(binders.length);
    var componentChildViews = ListWrapper.createFixedSize(binders.length);
    for (var binderIdx = 0; binderIdx < binders.length; binderIdx++) {
      var binder = binders[binderIdx];
      var elementInjector = null;
      // elementInjectors and rootElementInjectors
      var protoElementInjector = binder.protoElementInjector;
      if (isPresent(protoElementInjector)) {
        if (isPresent(protoElementInjector.parent)) {
          var parentElementInjector =
              elementInjectors[protoElementInjector.parent.index];
          elementInjector =
              protoElementInjector.instantiate(parentElementInjector);
        } else {
          elementInjector = protoElementInjector.instantiate(null);
          ListWrapper.push(rootElementInjectors, elementInjector);
        }
      }
      elementInjectors[binderIdx] = elementInjector;
      // preBuiltObjects
      if (isPresent(elementInjector)) {
        var embeddedProtoView =
            binder.hasEmbeddedProtoView() ? binder.nestedProtoView : null;
        preBuiltObjects[binderIdx] =
            new eli.PreBuiltObjects(viewManager, view, embeddedProtoView);
      }
    }
    view.init(changeDetector, elementInjectors, rootElementInjectors,
        preBuiltObjects, componentChildViews);
    return view;
  }
  attachComponentView(viewModule.AppView hostView, num boundElementIndex,
      viewModule.AppView componentView) {
    var childChangeDetector = componentView.changeDetector;
    hostView.changeDetector.addShadowDomChild(childChangeDetector);
    hostView.componentChildViews[boundElementIndex] = componentView;
  }
  detachComponentView(viewModule.AppView hostView, num boundElementIndex) {
    var componentView = hostView.componentChildViews[boundElementIndex];
    hostView.changeDetector.removeShadowDomChild(componentView.changeDetector);
    hostView.componentChildViews[boundElementIndex] = null;
  }
  hydrateComponentView(viewModule.AppView hostView, num boundElementIndex,
      [Injector injector = null]) {
    var elementInjector = hostView.elementInjectors[boundElementIndex];
    var componentView = hostView.componentChildViews[boundElementIndex];
    var component = this.getComponentInstance(hostView, boundElementIndex);
    this._hydrateView(
        componentView, injector, elementInjector, component, null);
  }
  attachAndHydrateInPlaceHostView(viewModule.AppView parentComponentHostView,
      num parentComponentBoundElementIndex, viewModule.AppView hostView,
      [Injector injector = null]) {
    var hostElementInjector = null;
    if (isPresent(parentComponentHostView)) {
      hostElementInjector = parentComponentHostView.elementInjectors[
          parentComponentBoundElementIndex];
      var parentView = parentComponentHostView.componentChildViews[
          parentComponentBoundElementIndex];
      parentView.changeDetector.addChild(hostView.changeDetector);
      ListWrapper.push(parentView.inPlaceHostViews, hostView);
    }
    this._hydrateView(
        hostView, injector, hostElementInjector, new Object(), null);
  }
  detachInPlaceHostView(
      viewModule.AppView parentView, viewModule.AppView hostView) {
    if (isPresent(parentView)) {
      parentView.changeDetector.removeChild(hostView.changeDetector);
      ListWrapper.remove(parentView.inPlaceHostViews, hostView);
    }
  }
  attachViewInContainer(viewModule.AppView parentView, num boundElementIndex,
      viewModule.AppView contextView, num contextBoundElementIndex, num atIndex,
      viewModule.AppView view) {
    if (isBlank(contextView)) {
      contextView = parentView;
      contextBoundElementIndex = boundElementIndex;
    }
    parentView.changeDetector.addChild(view.changeDetector);
    var viewContainer = parentView.viewContainers[boundElementIndex];
    if (isBlank(viewContainer)) {
      viewContainer = new viewModule.AppViewContainer();
      parentView.viewContainers[boundElementIndex] = viewContainer;
    }
    ListWrapper.insert(viewContainer.views, atIndex, view);
    var sibling;
    if (atIndex == 0) {
      sibling = null;
    } else {
      sibling = ListWrapper
          .last(viewContainer.views[atIndex - 1].rootElementInjectors);
    }
    var elementInjector =
        contextView.elementInjectors[contextBoundElementIndex];
    for (var i = view.rootElementInjectors.length - 1; i >= 0; i--) {
      view.rootElementInjectors[i].linkAfter(elementInjector, sibling);
    }
  }
  detachViewInContainer(
      viewModule.AppView parentView, num boundElementIndex, num atIndex) {
    var viewContainer = parentView.viewContainers[boundElementIndex];
    var view = viewContainer.views[atIndex];
    view.changeDetector.remove();
    ListWrapper.removeAt(viewContainer.views, atIndex);
    for (var i = 0; i < view.rootElementInjectors.length; ++i) {
      view.rootElementInjectors[i].unlink();
    }
  }
  hydrateViewInContainer(viewModule.AppView parentView, num boundElementIndex,
      viewModule.AppView contextView, num contextBoundElementIndex, num atIndex,
      Injector injector) {
    if (isBlank(contextView)) {
      contextView = parentView;
      contextBoundElementIndex = boundElementIndex;
    }
    var viewContainer = parentView.viewContainers[boundElementIndex];
    var view = viewContainer.views[atIndex];
    var elementInjector =
        contextView.elementInjectors[contextBoundElementIndex].getHost();
    this._hydrateView(view, injector, elementInjector, contextView.context,
        contextView.locals);
  }
  hydrateDynamicComponentInElementInjector(viewModule.AppView hostView,
      num boundElementIndex, Binding componentBinding,
      [Injector injector = null]) {
    var elementInjector = hostView.elementInjectors[boundElementIndex];
    if (isPresent(elementInjector.getDynamicallyLoadedComponent())) {
      throw new BaseException(
          '''There already is a dynamic component loaded at element ${ boundElementIndex}''');
    }
    if (isBlank(injector)) {
      injector = elementInjector.getLightDomAppInjector();
    }
    var annotation =
        this._metadataReader.read(componentBinding.token).annotation;
    var componentDirective =
        eli.DirectiveBinding.createFromBinding(componentBinding, annotation);
    elementInjector.dynamicallyCreateComponent(componentDirective, injector);
  }
  _hydrateView(viewModule.AppView view, Injector appInjector,
      eli.ElementInjector hostElementInjector, Object context,
      Locals parentLocals) {
    if (isBlank(appInjector)) {
      appInjector = hostElementInjector.getShadowDomAppInjector();
    }
    if (isBlank(appInjector)) {
      appInjector = hostElementInjector.getLightDomAppInjector();
    }
    view.context = context;
    view.locals.parent = parentLocals;
    var binders = view.proto.elementBinders;
    for (var i = 0; i < binders.length; ++i) {
      var elementInjector = view.elementInjectors[i];
      if (isPresent(elementInjector)) {
        elementInjector.instantiateDirectives(
            appInjector, hostElementInjector, view.preBuiltObjects[i]);
        this._setUpEventEmitters(view, elementInjector, i);
        this._setUpHostActions(view, elementInjector, i);
        // The exporting of $implicit is a special case. Since multiple elements will all export

        // the different values as $implicit, directly assign $implicit bindings to the variable

        // name.
        var exportImplicitName = elementInjector.getExportImplicitName();
        if (elementInjector.isExportingComponent()) {
          view.locals.set(exportImplicitName, elementInjector.getComponent());
        } else if (elementInjector.isExportingElement()) {
          view.locals.set(
              exportImplicitName, elementInjector.getElementRef().domElement);
        }
      }
    }
    view.changeDetector.hydrate(view.context, view.locals, view);
  }
  _setUpEventEmitters(viewModule.AppView view,
      eli.ElementInjector elementInjector, num boundElementIndex) {
    var emitters = elementInjector.getEventEmitterAccessors();
    for (var directiveIndex = 0;
        directiveIndex < emitters.length;
        ++directiveIndex) {
      var directiveEmitters = emitters[directiveIndex];
      var directive = elementInjector.getDirectiveAtIndex(directiveIndex);
      for (var eventIndex = 0;
          eventIndex < directiveEmitters.length;
          ++eventIndex) {
        var eventEmitterAccessor = directiveEmitters[eventIndex];
        eventEmitterAccessor.subscribe(view, boundElementIndex, directive);
      }
    }
  }
  _setUpHostActions(viewModule.AppView view,
      eli.ElementInjector elementInjector, num boundElementIndex) {
    var hostActions = elementInjector.getHostActionAccessors();
    for (var directiveIndex = 0;
        directiveIndex < hostActions.length;
        ++directiveIndex) {
      var directiveHostActions = hostActions[directiveIndex];
      var directive = elementInjector.getDirectiveAtIndex(directiveIndex);
      for (var index = 0; index < directiveHostActions.length; ++index) {
        var hostActionAccessor = directiveHostActions[index];
        hostActionAccessor.subscribe(view, boundElementIndex, directive);
      }
    }
  }
  dehydrateView(viewModule.AppView view) {
    var binders = view.proto.elementBinders;
    for (var i = 0; i < binders.length; ++i) {
      var elementInjector = view.elementInjectors[i];
      if (isPresent(elementInjector)) {
        elementInjector.clearDirectives();
      }
    }
    if (isPresent(view.locals)) {
      view.locals.clearValues();
    }
    view.context = null;
    view.changeDetector.dehydrate();
  }
}
