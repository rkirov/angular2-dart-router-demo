library angular2.src.render.dom.view.view;

import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, StringMapWrapper, List;
import "package:angular2/src/facade/lang.dart"
    show int, isPresent, isBlank, BaseException;
import "view_container.dart" show ViewContainer;
import "proto_view.dart" show RenderProtoView;
import "../shadow_dom/light_dom.dart" show LightDom;
import "../shadow_dom/content_tag.dart"
    show Content; // import {EventDispatcher} from '../../api';

const NG_BINDING_CLASS =
    "ng-binding"; /**
 * Const of making objects: http://jsperf.com/instantiate-size-of-object
 */
class RenderView {
  List boundElements;
  List boundTextNodes; /// When the view is part of render tree, the DocumentFragment is empty, which is why we need
  /// to keep track of the nodes.
  List rootNodes; // TODO(tbosch): move componentChildViews, viewContainers, contentTags, lightDoms into
  // a single array with records inside
  List<RenderView> componentChildViews;
  List<ViewContainer> viewContainers;
  List<Content> contentTags;
  List<LightDom> lightDoms;
  LightDom hostLightDom;
  RenderProtoView proto;
  bool hydrated;
  dynamic _eventDispatcher;
  List<Function> eventHandlerRemovers; /// Host views that were added by an imperative view.
  /// This is a dynamically growing / shrinking array.
  List<RenderView> imperativeHostViews;
  RenderView(RenderProtoView proto, List rootNodes, List boundTextNodes,
      List boundElements, List contentTags) {
    this.proto = proto;
    this.rootNodes = rootNodes;
    this.boundTextNodes = boundTextNodes;
    this.boundElements = boundElements;
    this.viewContainers = ListWrapper.createFixedSize(boundElements.length);
    this.contentTags = contentTags;
    this.lightDoms = ListWrapper.createFixedSize(boundElements.length);
    ListWrapper.fill(this.lightDoms, null);
    this.componentChildViews =
        ListWrapper.createFixedSize(boundElements.length);
    this.hostLightDom = null;
    this.hydrated = false;
    this.eventHandlerRemovers = [];
    this.imperativeHostViews = [];
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
  getOrCreateViewContainer(binderIndex) {
    var vc = this.viewContainers[binderIndex];
    if (isBlank(vc)) {
      vc = new ViewContainer(this, binderIndex);
      this.viewContainers[binderIndex] = vc;
    }
    return vc;
  }
  setElementProperty(num elementIndex, String propertyName, dynamic value) {
    var setter = MapWrapper.get(
        this.proto.elementBinders[elementIndex].propertySetters, propertyName);
    setter(this.boundElements[elementIndex], value);
  }
  setText(num textIndex, String value) {
    DOM.setText(this.boundTextNodes[textIndex], value);
  }
  ViewContainer getViewContainer(num index) {
    return this.viewContainers[index];
  }
  setEventDispatcher(dynamic dispatcher) {
    this._eventDispatcher = dispatcher;
  }
  bool dispatchEvent(elementIndex, eventName, event) {
    var allowDefaultBehavior = true;
    if (isPresent(this._eventDispatcher)) {
      var evalLocals = MapWrapper.create();
      MapWrapper.set(evalLocals, "\$event",
          event); // TODO(tbosch): reenable this when we are parsing element properties
      // out of action expressions
      // var localValues = this.proto.elementBinders[elementIndex].eventLocals.eval(null, new Locals(null, evalLocals));
      // this._eventDispatcher.dispatchEvent(elementIndex, eventName, localValues);
      allowDefaultBehavior = this._eventDispatcher.dispatchEvent(
          elementIndex, eventName, evalLocals);
      if (!allowDefaultBehavior) {
        event.preventDefault();
      }
    }
    return allowDefaultBehavior;
  }
}
