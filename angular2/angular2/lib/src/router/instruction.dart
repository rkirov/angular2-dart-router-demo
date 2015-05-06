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
  Instruction({params, component, children, matchedUrl}) {
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
  } /**
   * Takes a function:
   * (parent:Instruction, child:Instruction) => {}
   */
  traverseSync(Function fn) {
    this.forEachChild((childInstruction, _) => fn(this, childInstruction));
    this.forEachChild(
        (childInstruction, _) => childInstruction.traverseSync(fn));
  }
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
