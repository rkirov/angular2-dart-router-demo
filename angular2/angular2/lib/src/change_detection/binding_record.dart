library angular2.src.change_detection.binding_record;

import "package:angular2/src/facade/lang.dart" show isPresent, isBlank;
import "package:angular2/src/reflection/types.dart" show SetterFn;
import "parser/ast.dart" show AST;
import "directive_record.dart" show DirectiveIndex, DirectiveRecord;

const DIRECTIVE = "directive";
const ELEMENT = "element";
const TEXT_NODE = "textNode";
class BindingRecord {
  String mode;
  AST ast;
  dynamic implicitReceiver;
  num elementIndex;
  String propertyName;
  SetterFn setter;
  DirectiveRecord directiveRecord;
  BindingRecord(String mode, dynamic implicitReceiver, AST ast,
      num elementIndex, String propertyName, SetterFn setter,
      DirectiveRecord directiveRecord) {
    this.mode = mode;
    this.implicitReceiver = implicitReceiver;
    this.ast = ast;
    this.elementIndex = elementIndex;
    this.propertyName = propertyName;
    this.setter = setter;
    this.directiveRecord = directiveRecord;
  }
  callOnChange() {
    return isPresent(this.directiveRecord) && this.directiveRecord.callOnChange;
  }
  isOnPushChangeDetection() {
    return isPresent(this.directiveRecord) &&
        this.directiveRecord.isOnPushChangeDetection();
  }
  isDirective() {
    return identical(this.mode, DIRECTIVE);
  }
  isElement() {
    return identical(this.mode, ELEMENT);
  }
  isTextNode() {
    return identical(this.mode, TEXT_NODE);
  }
  static createForDirective(AST ast, String propertyName, SetterFn setter,
      DirectiveRecord directiveRecord) {
    return new BindingRecord(
        DIRECTIVE, 0, ast, 0, propertyName, setter, directiveRecord);
  }
  static createForElement(AST ast, num elementIndex, String propertyName) {
    return new BindingRecord(
        ELEMENT, 0, ast, elementIndex, propertyName, null, null);
  }
  static createForHostProperty(
      DirectiveIndex directiveIndex, AST ast, String propertyName) {
    return new BindingRecord(ELEMENT, directiveIndex, ast,
        directiveIndex.elementIndex, propertyName, null, null);
  }
  static createForTextNode(AST ast, num elementIndex) {
    return new BindingRecord(TEXT_NODE, 0, ast, elementIndex, null, null, null);
  }
}
