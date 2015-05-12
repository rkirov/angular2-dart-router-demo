library angular2.src.render.dom.view.proto_view;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/collection.dart" show List;
import "element_binder.dart" show ElementBinder;
import "../util.dart" show NG_BINDING_CLASS;
import "../../api.dart" show RenderProtoViewRef;

resolveInternalDomProtoView(RenderProtoViewRef protoViewRef) {
  DomProtoViewRef domProtoViewRef = protoViewRef;
  return domProtoViewRef._protoView;
}
class DomProtoViewRef extends RenderProtoViewRef {
  DomProtoView _protoView;
  DomProtoViewRef(DomProtoView protoView) : super() {
    /* super call moved to initializer */;
    this._protoView = protoView;
  }
}
class DomProtoView {
  var element;
  List<ElementBinder> elementBinders;
  bool isTemplateElement;
  int rootBindingOffset;
  DomProtoView({elementBinders, element}) {
    this.element = element;
    this.elementBinders = elementBinders;
    this.isTemplateElement = DOM.isTemplateElement(this.element);
    this.rootBindingOffset = (isPresent(this.element) &&
        DOM.hasClass(this.element, NG_BINDING_CLASS)) ? 1 : 0;
  }
}
