library angular2.src.render.dom.view.view_factory;

import "package:angular2/src/di/annotations_impl.dart" show Inject, Injectable;
import "package:angular2/src/facade/lang.dart"
    show int, isPresent, isBlank, BaseException;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, StringMapWrapper, List;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "../shadow_dom/content_tag.dart" show Content;
import "../shadow_dom/shadow_dom_strategy.dart" show ShadowDomStrategy;
import "package:angular2/src/render/dom/events/event_manager.dart"
    show EventManager;
import "proto_view.dart" as pvModule;
import "view.dart" as viewModule;
import "../util.dart"
    show
        NG_BINDING_CLASS_SELECTOR,
        NG_BINDING_CLASS; // TODO(tbosch): Make this an OpaqueToken as soon as our transpiler supports this!

const VIEW_POOL_CAPACITY = "render.ViewFactory.viewPoolCapacity";
@Injectable()
class ViewFactory {
  num _poolCapacityPerProtoView;
  Map<pvModule.RenderProtoView, List<viewModule.RenderView>> _pooledViewsPerProtoView;
  EventManager _eventManager;
  ShadowDomStrategy _shadowDomStrategy;
  ViewFactory(@Inject(VIEW_POOL_CAPACITY) poolCapacityPerProtoView,
      EventManager eventManager, ShadowDomStrategy shadowDomStrategy) {
    this._poolCapacityPerProtoView = poolCapacityPerProtoView;
    this._pooledViewsPerProtoView = MapWrapper.create();
    this._eventManager = eventManager;
    this._shadowDomStrategy = shadowDomStrategy;
  }
  viewModule.RenderView createInPlaceHostView(
      hostElementSelector, pvModule.RenderProtoView hostProtoView) {
    return this._createView(hostProtoView, hostElementSelector);
  }
  viewModule.RenderView getView(pvModule.RenderProtoView protoView) {
    var pooledViews = MapWrapper.get(this._pooledViewsPerProtoView, protoView);
    if (isPresent(pooledViews) && pooledViews.length > 0) {
      return ListWrapper.removeLast(pooledViews);
    }
    return this._createView(protoView, null);
  }
  returnView(viewModule.RenderView view) {
    if (view.hydrated) {
      throw new BaseException("View is still hydrated");
    }
    var protoView = view.proto;
    var pooledViews = MapWrapper.get(this._pooledViewsPerProtoView, protoView);
    if (isBlank(pooledViews)) {
      pooledViews = [];
      MapWrapper.set(this._pooledViewsPerProtoView, protoView, pooledViews);
    }
    if (pooledViews.length < this._poolCapacityPerProtoView) {
      ListWrapper.push(pooledViews, view);
    }
  }
  viewModule.RenderView _createView(
      pvModule.RenderProtoView protoView, inplaceElement) {
    if (isPresent(protoView.imperativeRendererId)) {
      return new viewModule.RenderView(protoView, [], [], [], []);
    }
    var rootElementClone = isPresent(inplaceElement)
        ? inplaceElement
        : DOM.importIntoDoc(protoView.element);
    var elementsWithBindingsDynamic;
    if (protoView.isTemplateElement) {
      elementsWithBindingsDynamic = DOM.querySelectorAll(
          DOM.content(rootElementClone), NG_BINDING_CLASS_SELECTOR);
    } else {
      elementsWithBindingsDynamic =
          DOM.getElementsByClassName(rootElementClone, NG_BINDING_CLASS);
    }
    var elementsWithBindings =
        ListWrapper.createFixedSize(elementsWithBindingsDynamic.length);
    for (var binderIdx = 0;
        binderIdx < elementsWithBindingsDynamic.length;
        ++binderIdx) {
      elementsWithBindings[binderIdx] = elementsWithBindingsDynamic[binderIdx];
    }
    var viewRootNodes;
    if (protoView.isTemplateElement) {
      var childNode = DOM.firstChild(DOM.content(rootElementClone));
      viewRootNodes = [
      ]; // Note: An explicit loop is the fastest way to convert a DOM array into a JS array!
      while (childNode != null) {
        ListWrapper.push(viewRootNodes, childNode);
        childNode = DOM.nextSibling(childNode);
      }
    } else {
      viewRootNodes = [rootElementClone];
    }
    var binders = protoView.elementBinders;
    var boundTextNodes = [];
    var boundElements = ListWrapper.createFixedSize(binders.length);
    var contentTags = ListWrapper.createFixedSize(binders.length);
    for (var binderIdx = 0; binderIdx < binders.length; binderIdx++) {
      var binder = binders[binderIdx];
      var element;
      if (identical(binderIdx, 0) &&
          identical(protoView.rootBindingOffset, 1)) {
        element = rootElementClone;
      } else {
        element = elementsWithBindings[binderIdx - protoView.rootBindingOffset];
      }
      boundElements[binderIdx] = element; // boundTextNodes
      var childNodes = DOM.childNodes(DOM.templateAwareRoot(element));
      var textNodeIndices = binder.textNodeIndices;
      for (var i = 0; i < textNodeIndices.length; i++) {
        ListWrapper.push(boundTextNodes, childNodes[textNodeIndices[i]]);
      } // contentTags
      var contentTag = null;
      if (isPresent(binder.contentTagSelector)) {
        contentTag = new Content(element, binder.contentTagSelector);
      }
      contentTags[binderIdx] = contentTag;
    }
    var view = new viewModule.RenderView(
        protoView, viewRootNodes, boundTextNodes, boundElements, contentTags);
    for (var binderIdx = 0; binderIdx < binders.length; binderIdx++) {
      var binder = binders[binderIdx];
      var element = boundElements[binderIdx]; // static child components
      if (binder.hasStaticComponent()) {
        var childView = this._createView(binder.nestedProtoView, null);
        ViewFactory.setComponentView(
            this._shadowDomStrategy, view, binderIdx, childView);
      } // events
      if (isPresent(binder.eventLocals) && isPresent(binder.localEvents)) {
        for (var i = 0; i < binder.localEvents.length; i++) {
          this._createEventListener(view, element, binderIdx,
              binder.localEvents[i].name, binder.eventLocals);
        }
      }
    }
    return view;
  }
  _createEventListener(view, element, elementIndex, eventName, eventLocals) {
    this._eventManager.addEventListener(element, eventName, (event) {
      view.dispatchEvent(elementIndex, eventName, event);
    });
  } // This method is used by the ViewFactory and the ViewHydrator
  // TODO(tbosch): change shadow dom emulation so that LightDom
  // instances don't need to be recreated by instead hydrated/dehydrated
  static setComponentView(ShadowDomStrategy shadowDomStrategy,
      viewModule.RenderView hostView, num elementIndex,
      viewModule.RenderView componentView) {
    var element = hostView.boundElements[elementIndex];
    var lightDom =
        shadowDomStrategy.constructLightDom(hostView, componentView, element);
    shadowDomStrategy.attachTemplate(element, componentView);
    hostView.lightDoms[elementIndex] = lightDom;
    hostView.componentChildViews[elementIndex] = componentView;
  }
}
