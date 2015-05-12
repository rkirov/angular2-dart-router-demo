library angular2.src.change_detection.proto_record;

import "package:angular2/src/facade/collection.dart" show List;
import "binding_record.dart" show BindingRecord;
import "directive_record.dart" show DirectiveIndex;
// HACK: workaround for Traceur behavior.

// It expects all transpiled modules to contain this marker.

// TODO: remove this when we no longer use traceur
var ___esModule = true;
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
  var funcOrValue;
  List<dynamic> args;
  List<dynamic> fixedArgs;
  num contextIndex;
  DirectiveIndex directiveIndex;
  num selfIndex;
  BindingRecord bindingRecord;
  String expressionAsString;
  bool lastInBinding;
  bool lastInDirective;
  ProtoRecord(this.mode, this.name, this.funcOrValue, this.args, this.fixedArgs,
      this.contextIndex, this.directiveIndex, this.selfIndex,
      this.bindingRecord, this.expressionAsString, this.lastInBinding,
      this.lastInDirective) {}
  bool isPureFunction() {
    return identical(this.mode, RECORD_TYPE_INTERPOLATE) ||
        identical(this.mode, RECORD_TYPE_PRIMITIVE_OP);
  }
}
