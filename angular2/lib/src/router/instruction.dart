library angular2.src.router.instruction;

import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, Map, StringMapWrapper, List, ListWrapper;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent;

class RouteParams {
  Map<String, String> params;
  RouteParams(Map params) {
    this.params = params;
  }
  get(String param) {
    return StringMapWrapper.get(this.params, param);
  }
}
class Instruction {
  dynamic component;
  Map<String, Instruction> _children;
  dynamic router;
  String matchedUrl;
  Map<String, String> params;
  bool reuse;
  Instruction({params, component, children, matchedUrl}) {
    this.reuse = false;
    this.matchedUrl = matchedUrl;
    if (isPresent(children)) {
      this._children = children;
      var childUrl;
      StringMapWrapper.forEach(this._children, (child, _) {
        childUrl = child.matchedUrl;
      });
      if (isPresent(childUrl)) {
        this.matchedUrl += childUrl;
      }
    } else {
      this._children = StringMapWrapper.create();
    }
    this.component = component;
    this.params = params;
  }
  getChildInstruction(String outletName) {
    return StringMapWrapper.get(this._children, outletName);
  }
  forEachChild(Function fn) {
    StringMapWrapper.forEach(this._children, fn);
  }
  Future mapChildrenAsync(fn) {
    return mapObjAsync(this._children, fn);
  }
  /**
   * Does a synchronous, breadth-first traversal of the graph of instructions.
   * Takes a function with signature:
   * (parent:Instruction, child:Instruction) => {}
   */
  traverseSync(Function fn) {
    this.forEachChild((childInstruction, _) => fn(this, childInstruction));
    this.forEachChild(
        (childInstruction, _) => childInstruction.traverseSync(fn));
  }
  /**
   * Does an asynchronous, breadth-first traversal of the graph of instructions.
   * Takes a function with signature:
   * (child:Instruction, parentOutletName:string) => {}
   */
  traverseAsync(Function fn) {
    return this.mapChildrenAsync(fn).then((_) => this.mapChildrenAsync(
        (childInstruction, _) => childInstruction.traverseAsync(fn)));
  }
  /**
   * Takes a currently active instruction and sets a reuse flag on this instruction
   */
  reuseComponentsFrom(Instruction oldInstruction) {
    this.forEachChild((childInstruction, outletName) {
      var oldInstructionChild = oldInstruction.getChildInstruction(outletName);
      if (shouldReuseComponent(childInstruction, oldInstructionChild)) {
        childInstruction.reuse = true;
      }
    });
  }
}
shouldReuseComponent(Instruction instr1, Instruction instr2) {
  return instr1.component == instr2.component &&
      StringMapWrapper.equals(instr1.params, instr2.params);
}
mapObjAsync(Map obj, fn) {
  return PromiseWrapper.all(mapObj(obj, fn));
}
List mapObj(Map obj, fn) {
  var result = ListWrapper.create();
  StringMapWrapper.forEach(
      obj, (value, key) => ListWrapper.push(result, fn(value, key)));
  return result;
}
var noopInstruction = new Instruction();
