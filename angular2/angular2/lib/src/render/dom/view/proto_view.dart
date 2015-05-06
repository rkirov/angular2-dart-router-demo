library angular2.src.render.dom.view.proto_view;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/collection.dart"
    show List, Map, ListWrapper, MapWrapper;
import "element_binder.dart" show ElementBinder;
import "../util.dart" show NG_BINDING_CLASS;

class RenderProtoView {
  var element;
  List<ElementBinder> elementBinders;
  bool isTemplateElement;
  int rootBindingOffset;
  String imperativeRendererId;
  RenderProtoView({elementBinders, element, imperativeRendererId}) {
    this.element = element;
    this.elementBinders = elementBinders;
    this.imperativeRendererId = imperativeRendererId;
    if (isPresent(imperativeRendererId)) {
      this.rootBindingOffset = 0;
      this.isTemplateElement = false;
    } else {
      this.isTemplateElement = DOM.isTemplateElement(this.element);
      this.rootBindingOffset = (isPresent(this.element) &&
          DOM.hasClass(this.element, NG_BINDING_CLASS)) ? 1 : 0;
    }
  }
  mergeChildComponentProtoViews(List<RenderProtoView> componentProtoViews) {
    var componentProtoViewIndex = 0;
    for (var i = 0; i < this.elementBinders.length; i++) {
      var eb = this.elementBinders[i];
      if (isPresent(eb.componentId)) {
        eb.nestedProtoView = componentProtoViews[componentProtoViewIndex];
        componentProtoViewIndex++;
      }
    }
  }
}
