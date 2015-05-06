library angular2.src.change_detection.proto_record;

import "package:angular2/src/facade/collection.dart" show List;
import "binding_record.dart" show BindingRecord;
import "directive_record.dart" show DirectiveIndex;

const RECORD_TYPE_SELF = 0;
const RECORD_TYPE_CONST = 1;
const RECORD_TYPE_PRIMITIVE_OP = 2;
const RECORD_TYPE_PROPERTY = 3;
const RECORD_TYPE_LOCAL = 4;
const RECORD_TYPE_INVOKE_METHOD = 5;
const RECORD_TYPE_INVOKE_CLOSURE = 6;
const RECORD_TYPE_KEYED_ACCESS = 7;
const RECORD_TYPE_PIPE = 8;
const RECORD_TYPE_BINDING_PIPE = 9;
const RECORD_TYPE_INTERPOLATE = 10;
class ProtoRecord {
  num mode;
  String name;
  dynamic funcOrValue;
  List args;
  List fixedArgs;
  num contextIndex;
  DirectiveIndex directiveIndex;
  num selfIndex;
  BindingRecord bindingRecord;
  bool lastInBinding;
  bool lastInDirective;
  String expressionAsString;
  ProtoRecord(num mode, String name, funcOrValue, List args, List fixedArgs,
      num contextIndex, DirectiveIndex directiveIndex, num selfIndex,
      BindingRecord bindingRecord, String expressionAsString,
      bool lastInBinding, bool lastInDirective) {
    this.mode = mode;
    this.name = name;
    this.funcOrValue = funcOrValue;
    this.args = args;
    this.fixedArgs = fixedArgs;
    this.contextIndex = contextIndex;
    this.directiveIndex = directiveIndex;
    this.selfIndex = selfIndex;
    this.bindingRecord = bindingRecord;
    this.lastInBinding = lastInBinding;
    this.lastInDirective = lastInDirective;
    this.expressionAsString = expressionAsString;
  }
  bool isPureFunction() {
    return identical(this.mode, RECORD_TYPE_INTERPOLATE) ||
        identical(this.mode, RECORD_TYPE_PRIMITIVE_OP);
  }
}
