library angular2.src.test_lib.utils;

import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/lang.dart" show isPresent;

class Log {
  List _result;
  Log() {
    this._result = [];
  }
  add(value) {
    ListWrapper.push(this._result, value);
  }
  fn(value) {
    return ([a1 = null, a2 = null, a3 = null, a4 = null, a5 = null]) {
      ListWrapper.push(this._result, value);
    };
  }
  result() {
    return ListWrapper.join(this._result, "; ");
  }
}
viewRootNodes(view) {
  return view.render.delegate.rootNodes;
}
queryView(view, selector) {
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
el(html) {
  return DOM.firstChild(DOM.content(DOM.createTemplate(html)));
}
