library angular2.src.render.dom.dom_renderer;

import "package:angular2/src/di/annotations_impl.dart" show Inject, Injectable;
import "package:angular2/src/facade/lang.dart"
    show int, isPresent, isBlank, BaseException, RegExpWrapper;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, StringMapWrapper, List;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "shadow_dom/content_tag.dart" show Content;
import "shadow_dom/shadow_dom_strategy.dart" show ShadowDomStrategy;
import "events/event_manager.dart" show EventManager;
import "view/proto_view.dart"
    show DomProtoView, DomProtoViewRef, resolveInternalDomProtoView;
import "view/view.dart" show DomView, DomViewRef, resolveInternalDomView;
import "view/view_container.dart" show DomViewContainer;
import "util.dart" show NG_BINDING_CLASS_SELECTOR, NG_BINDING_CLASS;
import "../api.dart" show Renderer, RenderProtoViewRef, RenderViewRef;
// TODO(tbosch): use an OpaqueToken here once our transpiler supports

// const expressions!
const DOCUMENT_TOKEN = "DocumentToken";
var _DOCUMENT_SELECTOR_REGEX = RegExpWrapper.create("\\:document(.+)");
@Injectable()
class DomRenderer extends Renderer {
  EventManager _eventManager;
  ShadowDomStrategy _shadowDomStrategy;
  var _document;
  DomRenderer(EventManager eventManager, ShadowDomStrategy shadowDomStrategy,
      @Inject(DOCUMENT_TOKEN) document)
      : super() {
    /* super call moved to initializer */;
    this._eventManager = eventManager;
    this._shadowDomStrategy = shadowDomStrategy;
    this._document = document;
  }
  RenderViewRef createInPlaceHostView(RenderViewRef parentHostViewRef,
      String hostElementSelector, RenderProtoViewRef hostProtoViewRef) {
    var containerNode;
    var documentSelectorMatch =
        RegExpWrapper.firstMatch(_DOCUMENT_SELECTOR_REGEX, hostElementSelector);
    if (isPresent(documentSelectorMatch)) {
      containerNode = this._document;
      hostElementSelector = documentSelectorMatch[1];
    } else if (isPresent(parentHostViewRef)) {
      var parentHostView = resolveInternalDomView(parentHostViewRef);
      containerNode = parentHostView.shadowRoot;
    } else {
      containerNode = this._document;
    }
    var element = DOM.querySelector(containerNode, hostElementSelector);
    if (isBlank(element)) {
      throw new BaseException(
          '''The selector "${ hostElementSelector}" did not match any elements''');
    }
    var hostProtoView = resolveInternalDomProtoView(hostProtoViewRef);
    return new DomViewRef(this._createView(hostProtoView, element));
  }
  destroyInPlaceHostView(
      RenderViewRef parentHostViewRef, RenderViewRef hostViewRef) {
    var hostView = resolveInternalDomView(hostViewRef);
    this._removeViewNodes(hostView);
  }
  RenderViewRef createView(RenderProtoViewRef protoViewRef) {
    var protoView = resolveInternalDomProtoView(protoViewRef);
    return new DomViewRef(this._createView(protoView, null));
  }
  destroyView(RenderViewRef view) {}
  attachComponentView(RenderViewRef hostViewRef, num elementIndex,
      RenderViewRef componentViewRef) {
    var hostView = resolveInternalDomView(hostViewRef);
    var componentView = resolveInternalDomView(componentViewRef);
    var element = hostView.boundElements[elementIndex];
    var lightDom = hostView.lightDoms[elementIndex];
    if (isPresent(lightDom)) {
      lightDom.attachShadowDomView(componentView);
    }
    var shadowRoot = this._shadowDomStrategy.prepareShadowRoot(element);
    this._moveViewNodesIntoParent(shadowRoot, componentView);
    componentView.hostLightDom = lightDom;
    componentView.shadowRoot = shadowRoot;
  }
  setComponentViewRootNodes(RenderViewRef componentViewRef, List rootNodes) {
    var componentView = resolveInternalDomView(componentViewRef);
    this._removeViewNodes(componentView);
    componentView.rootNodes = rootNodes;
    this._moveViewNodesIntoParent(componentView.shadowRoot, componentView);
  }
  detachComponentView(RenderViewRef hostViewRef, num boundElementIndex,
      RenderViewRef componentViewRef) {
    var hostView = resolveInternalDomView(hostViewRef);
    var componentView = resolveInternalDomView(componentViewRef);
    this._removeViewNodes(componentView);
    var lightDom = hostView.lightDoms[boundElementIndex];
    if (isPresent(lightDom)) {
      lightDom.detachShadowDomView();
    }
    componentView.hostLightDom = null;
    componentView.shadowRoot = null;
  }
  attachViewInContainer(RenderViewRef parentViewRef, num boundElementIndex,
      num atIndex, RenderViewRef viewRef) {
    var parentView = resolveInternalDomView(parentViewRef);
    var view = resolveInternalDomView(viewRef);
    var viewContainer =
        this._getOrCreateViewContainer(parentView, boundElementIndex);
    ListWrapper.insert(viewContainer.views, atIndex, view);
    view.hostLightDom = parentView.hostLightDom;
    var directParentLightDom =
        parentView.getDirectParentLightDom(boundElementIndex);
    if (isBlank(directParentLightDom)) {
      var siblingToInsertAfter;
      if (atIndex == 0) {
        siblingToInsertAfter = parentView.boundElements[boundElementIndex];
      } else {
        siblingToInsertAfter =
            ListWrapper.last(viewContainer.views[atIndex - 1].rootNodes);
      }
      this._moveViewNodesAfterSibling(siblingToInsertAfter, view);
    } else {
      directParentLightDom.redistribute();
    }
    // new content tags might have appeared, we need to redistribute.
    if (isPresent(parentView.hostLightDom)) {
      parentView.hostLightDom.redistribute();
    }
  }
  detachViewInContainer(RenderViewRef parentViewRef, num boundElementIndex,
      num atIndex, RenderViewRef viewRef) {
    var parentView = resolveInternalDomView(parentViewRef);
    var view = resolveInternalDomView(viewRef);
    var viewContainer = parentView.viewContainers[boundElementIndex];
    var detachedView = viewContainer.views[atIndex];
    ListWrapper.removeAt(viewContainer.views, atIndex);
    var directParentLightDom =
        parentView.getDirectParentLightDom(boundElementIndex);
    if (isBlank(directParentLightDom)) {
      this._removeViewNodes(detachedView);
    } else {
      directParentLightDom.redistribute();
    }
    view.hostLightDom = null;
    // content tags might have disappeared we need to do redistribution.
    if (isPresent(parentView.hostLightDom)) {
      parentView.hostLightDom.redistribute();
    }
  }
  hydrateView(RenderViewRef viewRef) {
    var view = resolveInternalDomView(viewRef);
    if (view.hydrated) throw new BaseException("The view is already hydrated.");
    view.hydrated = true;
    for (var i = 0; i < view.lightDoms.length; ++i) {
      var lightDom = view.lightDoms[i];
      if (isPresent(lightDom)) {
        lightDom.redistribute();
      }
    }
    //add global events
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
    if (isPresent(view.hostLightDom)) {
      view.hostLightDom.redistribute();
    }
  }
  dehydrateView(RenderViewRef viewRef) {
    var view = resolveInternalDomView(viewRef);
    //remove global events
    for (var i = 0; i < view.eventHandlerRemovers.length; i++) {
      view.eventHandlerRemovers[i]();
    }
    view.eventHandlerRemovers = null;
    view.hydrated = false;
  }
  void setElementProperty(RenderViewRef viewRef, num elementIndex,
      String propertyName, dynamic propertyValue) {
    var view = resolveInternalDomView(viewRef);
    view.setElementProperty(elementIndex, propertyName, propertyValue);
  }
  void callAction(RenderViewRef viewRef, num elementIndex,
      String actionExpression, dynamic actionArgs) {
    var view = resolveInternalDomView(viewRef);
    view.callAction(elementIndex, actionExpression, actionArgs);
  }
  void setText(RenderViewRef viewRef, num textNodeIndex, String text) {
    var view = resolveInternalDomView(viewRef);
    DOM.setText(view.boundTextNodes[textNodeIndex], text);
  }
  void setEventDispatcher(RenderViewRef viewRef, dynamic dispatcher) {
    var view = resolveInternalDomView(viewRef);
    view.eventDispatcher = dispatcher;
  }
  DomView _createView(DomProtoView protoView, inplaceElement) {
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
      viewRootNodes = [];
      // Note: An explicit loop is the fastest way to convert a DOM array into a JS array!
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
      boundElements[binderIdx] = element;
      // boundTextNodes
      var childNodes = DOM.childNodes(DOM.templateAwareRoot(element));
      var textNodeIndices = binder.textNodeIndices;
      for (var i = 0; i < textNodeIndices.length; i++) {
        ListWrapper.push(boundTextNodes, childNodes[textNodeIndices[i]]);
      }
      // contentTags
      var contentTag = null;
      if (isPresent(binder.contentTagSelector)) {
        contentTag = new Content(element, binder.contentTagSelector);
      }
      contentTags[binderIdx] = contentTag;
    }
    var view = new DomView(
        protoView, viewRootNodes, boundTextNodes, boundElements, contentTags);
    for (var binderIdx = 0; binderIdx < binders.length; binderIdx++) {
      var binder = binders[binderIdx];
      var element = boundElements[binderIdx];
      // lightDoms
      var lightDom = null;
      if (isPresent(binder.componentId)) {
        lightDom = this._shadowDomStrategy.constructLightDom(
            view, boundElements[binderIdx]);
      }
      view.lightDoms[binderIdx] = lightDom;
      // init contentTags
      var contentTag = contentTags[binderIdx];
      if (isPresent(contentTag)) {
        var destLightDom = view.getDirectParentLightDom(binderIdx);
        contentTag.init(destLightDom);
      }
      // events
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
  }
  _moveViewNodesAfterSibling(sibling, view) {
    for (var i = view.rootNodes.length - 1; i >= 0; --i) {
      DOM.insertAfter(sibling, view.rootNodes[i]);
    }
  }
  _moveViewNodesIntoParent(parent, view) {
    for (var i = 0; i < view.rootNodes.length; ++i) {
      DOM.appendChild(parent, view.rootNodes[i]);
    }
  }
  _removeViewNodes(view) {
    var len = view.rootNodes.length;
    if (len == 0) return;
    var parent = view.rootNodes[0].parentNode;
    for (var i = len - 1; i >= 0; --i) {
      DOM.removeChild(parent, view.rootNodes[i]);
    }
  }
  _getOrCreateViewContainer(DomView parentView, boundElementIndex) {
    var vc = parentView.viewContainers[boundElementIndex];
    if (isBlank(vc)) {
      vc = new DomViewContainer();
      parentView.viewContainers[boundElementIndex] = vc;
    }
    return vc;
  }
  Function _createGlobalEventListener(
      view, elementIndex, eventName, eventTarget, fullName) {
    return this._eventManager.addGlobalEventListener(eventTarget, eventName,
        (event) {
      view.dispatchEvent(elementIndex, fullName, event);
    });
  }
}
