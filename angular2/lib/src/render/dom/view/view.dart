library angular2.src.render.dom.view.view;

import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, StringMapWrapper, List;
import "package:angular2/change_detection.dart" show Locals;
import "package:angular2/src/facade/lang.dart"
    show int, isPresent, isBlank, BaseException;
import "view_container.dart" show DomViewContainer;
import "proto_view.dart" show DomProtoView;
import "../shadow_dom/light_dom.dart" show LightDom;
import "../shadow_dom/content_tag.dart" show Content;
import "../../api.dart" show RenderViewRef;
// TODO(tbosch): enable this again!

// import {EventDispatcher} from '../../api';
resolveInternalDomView(RenderViewRef viewRef) {
  DomViewRef domViewRef = viewRef;
  return domViewRef._view;
}
class DomViewRef extends RenderViewRef {
  DomView _view;
  DomViewRef(DomView view) : super() {
    /* super call moved to initializer */;
    this._view = view;
  }
}
const NG_BINDING_CLASS = "ng-binding";
/**
 * Const of making objects: http://jsperf.com/instantiate-size-of-object
 */
class DomView {
  List boundElements;
  List boundTextNodes;
  /// When the view is part of render tree, the DocumentFragment is empty, which is why we need

  /// to keep track of the nodes.
  List rootNodes;
  // TODO(tbosch): move componentChildViews, viewContainers, contentTags, lightDoms into

  // a single array with records inside
  List<DomViewContainer> viewContainers;
  List<Content> contentTags;
  List<LightDom> lightDoms;
  LightDom hostLightDom;
  var shadowRoot;
  DomProtoView proto;
  bool hydrated;
  dynamic eventDispatcher;
  List<Function> eventHandlerRemovers;
  DomView(DomProtoView proto, List rootNodes, List boundTextNodes,
      List boundElements, List contentTags) {
    this.proto = proto;
    this.rootNodes = rootNodes;
    this.boundTextNodes = boundTextNodes;
    this.boundElements = boundElements;
    this.viewContainers = ListWrapper.createFixedSize(boundElements.length);
    this.contentTags = contentTags;
    this.lightDoms = ListWrapper.createFixedSize(boundElements.length);
    this.hostLightDom = null;
    this.hydrated = false;
    this.eventHandlerRemovers = [];
    this.eventDispatcher = null;
    this.shadowRoot = null;
  }
  getDirectParentLightDom(num boundElementIndex) {
    var binder = this.proto.elementBinders[boundElementIndex];
    var destLightDom = null;
    if (!identical(binder.parentIndex, -1) &&
        identical(binder.distanceToParent, 1)) {
      destLightDom = this.lightDoms[binder.parentIndex];
    }
    return destLightDom;
  }
  setElementProperty(num elementIndex, String propertyName, dynamic value) {
    var setter = MapWrapper.get(
        this.proto.elementBinders[elementIndex].propertySetters, propertyName);
    setter(this.boundElements[elementIndex], value);
  }
  callAction(num elementIndex, String actionExpression, dynamic actionArgs) {
    var binder = this.proto.elementBinders[elementIndex];
    var hostAction = MapWrapper.get(binder.hostActions, actionExpression);
    hostAction.eval(
        this.boundElements[elementIndex], this._localsWithAction(actionArgs));
  }
  Locals _localsWithAction(Object action) {
    var map = MapWrapper.create();
    MapWrapper.set(map, "\$action", action);
    return new Locals(null, map);
  }
  setText(num textIndex, String value) {
    DOM.setText(this.boundTextNodes[textIndex], value);
  }
  bool dispatchEvent(elementIndex, eventName, event) {
    var allowDefaultBehavior = true;
    if (isPresent(this.eventDispatcher)) {
      var evalLocals = MapWrapper.create();
      MapWrapper.set(evalLocals, "\$event", event);
      // TODO(tbosch): reenable this when we are parsing element properties

      // out of action expressions

      // var localValues = this.proto.elementBinders[elementIndex].eventLocals.eval(null, new Locals(null, evalLocals));

      // this.eventDispatcher.dispatchEvent(elementIndex, eventName, localValues);
      allowDefaultBehavior = this.eventDispatcher.dispatchEvent(
          elementIndex, eventName, evalLocals);
      if (!allowDefaultBehavior) {
        event.preventDefault();
      }
    }
    return allowDefaultBehavior;
  }
}
