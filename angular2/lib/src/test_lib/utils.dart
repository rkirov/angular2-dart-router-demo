library angular2.src.test_lib.utils;

import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/render/dom/view/view.dart"
    show resolveInternalDomView;

class Log {
  List _result;
  Log() {
    this._result = [];
  }
  void add(value) {
    ListWrapper.push(this._result, value);
  }
  fn(value) {
    return ([a1 = null, a2 = null, a3 = null, a4 = null, a5 = null]) {
      ListWrapper.push(this._result, value);
    };
  }
  String result() {
    return ListWrapper.join(this._result, "; ");
  }
}
List viewRootNodes(view) {
  return resolveInternalDomView(view.render).rootNodes;
}
queryView(view, String selector) {
  var rootNodes = viewRootNodes(view);
  for (var i = 0; i < rootNodes.length; ++i) {
    var res = DOM.querySelector(rootNodes[i], selector);
    if (isPresent(res)) {
      return res;
    }
  }
  return null;
}
dispatchEvent(element, eventType) {
  DOM.dispatchEvent(element, DOM.createEvent(eventType));
}
el(String html) {
  return DOM.firstChild(DOM.content(DOM.createTemplate(html)));
}
