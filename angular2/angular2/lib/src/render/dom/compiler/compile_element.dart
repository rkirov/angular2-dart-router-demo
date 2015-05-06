library angular2.src.render.dom.compiler.compile_element;

import "package:angular2/src/facade/collection.dart"
    show List, Map, ListWrapper, MapWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/lang.dart"
    show int, isBlank, isPresent, Type, StringJoiner, assertionsEnabled;
import "../view/proto_view_builder.dart"
    show
        ProtoViewBuilder,
        ElementBinderBuilder; /**
 * Collects all data that is needed to process an element
 * in the compile process. Fields are filled
 * by the CompileSteps starting out with the pure HTMLElement.
 */

class CompileElement {
  var element;
  Map _attrs;
  List _classList;
  bool isViewRoot;
  ProtoViewBuilder inheritedProtoView;
  num distanceToInheritedBinder;
  ElementBinderBuilder inheritedElementBinder;
  bool compileChildren;
  String elementDescription;
  CompileElement(element, [compilationUnit = ""]) {
    this.element = element;
    this._attrs = null;
    this._classList = null;
    this.isViewRoot = false; // inherited down to children if they don't have
    // an own protoView
    this.inheritedProtoView =
        null; // inherited down to children if they don't have
    // an own elementBinder
    this.inheritedElementBinder = null;
    this.distanceToInheritedBinder = 0;
    this.compileChildren =
        true; // description is calculated here as compilation steps may change the element
    var tplDesc = assertionsEnabled() ? getElementDescription(element) : null;
    if (!identical(compilationUnit, "")) {
      this.elementDescription = compilationUnit;
      if (isPresent(tplDesc)) this.elementDescription += ": " + tplDesc;
    } else {
      this.elementDescription = tplDesc;
    }
  }
  isBound() {
    return isPresent(this.inheritedElementBinder) &&
        identical(this.distanceToInheritedBinder, 0);
  }
  bindElement() {
    if (!this.isBound()) {
      var parentBinder = this.inheritedElementBinder;
      this.inheritedElementBinder = this.inheritedProtoView.bindElement(
          this.element, this.elementDescription);
      if (isPresent(parentBinder)) {
        this.inheritedElementBinder.setParent(
            parentBinder, this.distanceToInheritedBinder);
      }
      this.distanceToInheritedBinder = 0;
    }
    return this.inheritedElementBinder;
  }
  refreshAttrs() {
    this._attrs = null;
  }
  Map<String, String> attrs() {
    if (isBlank(this._attrs)) {
      this._attrs = DOM.attributeMap(this.element);
    }
    return this._attrs;
  }
  refreshClassList() {
    this._classList = null;
  }
  List<String> classList() {
    if (isBlank(this._classList)) {
      this._classList = ListWrapper.create();
      var elClassList = DOM.classList(this.element);
      for (var i = 0; i < elClassList.length; i++) {
        ListWrapper.push(this._classList, elClassList[i]);
      }
    }
    return this._classList;
  }
} // return an HTML representation of an element start tag - without its content
// this is used to give contextual information in case of errors
String getElementDescription(domElement) {
  var buf = new StringJoiner();
  var atts = DOM.attributeMap(domElement);
  buf.add("<");
  buf.add(DOM
      .tagName(domElement)
      .toLowerCase()); // show id and class first to ease element identification
  addDescriptionAttribute(buf, "id", MapWrapper.get(atts, "id"));
  addDescriptionAttribute(buf, "class", MapWrapper.get(atts, "class"));
  MapWrapper.forEach(atts, (attValue, attName) {
    if (!identical(attName, "id") && !identical(attName, "class")) {
      addDescriptionAttribute(buf, attName, attValue);
    }
  });
  buf.add(">");
  return buf.toString();
}
addDescriptionAttribute(StringJoiner buffer, String attName, attValue) {
  if (isPresent(attValue)) {
    if (identical(attValue.length, 0)) {
      buffer.add(" " + attName);
    } else {
      buffer.add(" " + attName + "=\"" + attValue + "\"");
    }
  }
}
