library angular2.src.router.instruction;

import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, Map, StringMapWrapper, List, ListWrapper;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent, normalizeBlank;

class RouteParams {
  Map<String, String> params;
  RouteParams(Map params) {
    this.params = params;
  }
  String get(String param) {
    return normalizeBlank(StringMapWrapper.get(this.params, param));
  }
}
/**
 * An `Instruction` represents the component hierarchy of the application based on a given route
 */
class Instruction {
  dynamic component;
  Map<String, Instruction> _children;
  // the part of the URL captured by this instruction
  String capturedUrl;
  // the part of the URL captured by this instruction and all children
  String accumulatedUrl;
  Map<String, String> params;
  bool reuse;
  num specificity;
  Instruction({params, component, children, matchedUrl, parentSpecificity}) {
    this.reuse = false;
    this.capturedUrl = matchedUrl;
    this.accumulatedUrl = matchedUrl;
    this.specificity = parentSpecificity;
    if (isPresent(children)) {
      this._children = children;
      var childUrl;
      StringMapWrapper.forEach(this._children, (child, _) {
        childUrl = child.accumulatedUrl;
        this.specificity += child.specificity;
      });
      if (isPresent(childUrl)) {
        this.accumulatedUrl += childUrl;
      }
    } else {
      this._children = StringMapWrapper.create();
    }
    this.component = component;
    this.params = params;
  }
  bool hasChild(String outletName) {
    return StringMapWrapper.contains(this._children, outletName);
  }
  /**
   * Returns the child instruction with the given outlet name
   */
  Instruction getChild(String outletName) {
    return StringMapWrapper.get(this._children, outletName);
  }
  /**
   * (child:Instruction, outletName:string) => {}
   */
  void forEachChild(Function fn) {
    StringMapWrapper.forEach(this._children, fn);
  }
  /**
   * Does a synchronous, breadth-first traversal of the graph of instructions.
   * Takes a function with signature:
   * (child:Instruction, outletName:string) => {}
   */
  void traverseSync(Function fn) {
    this.forEachChild(fn);
    this.forEachChild(
        (childInstruction, _) => childInstruction.traverseSync(fn));
  }
  /**
   * Takes a currently active instruction and sets a reuse flag on each of this instruction's children
   */
  void reuseComponentsFrom(Instruction oldInstruction) {
    this.traverseSync((childInstruction, outletName) {
      var oldInstructionChild = oldInstruction.getChild(outletName);
      if (shouldReuseComponent(childInstruction, oldInstructionChild)) {
        childInstruction.reuse = true;
      }
    });
  }
}
bool shouldReuseComponent(Instruction instr1, Instruction instr2) {
  return instr1.component == instr2.component &&
      StringMapWrapper.equals(instr1.params, instr2.params);
}
Future mapObjAsync(Map obj, fn) {
  return PromiseWrapper.all(mapObj(obj, fn));
}
List mapObj(Map obj, Function fn) {
  var result = ListWrapper.create();
  StringMapWrapper.forEach(
      obj, (value, key) => ListWrapper.push(result, fn(value, key)));
  return result;
}
