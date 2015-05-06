library angular2.src.render.dom.shadow_dom.util;

import "package:angular2/src/facade/lang.dart" show isBlank, isPresent, int;
import "package:angular2/src/facade/collection.dart" show MapWrapper, Map;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "shadow_css.dart" show ShadowCss;

moveViewNodesIntoParent(parent, view) {
  for (var i = 0; i < view.rootNodes.length; ++i) {
    DOM.appendChild(parent, view.rootNodes[i]);
  }
}
Map<String, int> _componentUIDs = MapWrapper.create();
int _nextComponentUID = 0;
Map<String, bool> _sharedStyleTexts = MapWrapper.create();
var _lastInsertedStyleEl;
getComponentId(String componentStringId) {
  var id = MapWrapper.get(_componentUIDs, componentStringId);
  if (isBlank(id)) {
    id = _nextComponentUID++;
    MapWrapper.set(_componentUIDs, componentStringId, id);
  }
  return id;
}
insertSharedStyleText(cssText, styleHost, styleEl) {
  if (!MapWrapper.contains(_sharedStyleTexts, cssText)) {
    // Styles are unscoped and shared across components, only append them to the head
    // when there are not present yet
    MapWrapper.set(_sharedStyleTexts, cssText, true);
    insertStyleElement(styleHost, styleEl);
  }
}
insertStyleElement(host, styleEl) {
  if (isBlank(_lastInsertedStyleEl)) {
    var firstChild = DOM.firstChild(host);
    if (isPresent(firstChild)) {
      DOM.insertBefore(firstChild, styleEl);
    } else {
      DOM.appendChild(host, styleEl);
    }
  } else {
    DOM.insertAfter(_lastInsertedStyleEl, styleEl);
  }
  _lastInsertedStyleEl = styleEl;
} // Return the attribute to be added to the component
getHostAttribute(int id) {
  return '''_nghost-${ id}''';
} // Returns the attribute to be added on every single element nodes in the component
getContentAttribute(int id) {
  return '''_ngcontent-${ id}''';
}
String shimCssForComponent(String cssText, String componentId) {
  var id = getComponentId(componentId);
  var shadowCss = new ShadowCss();
  return shadowCss.shimCssText(
      cssText, getContentAttribute(id), getHostAttribute(id));
} // Reset the caches - used for tests only
resetShadowDomCache() {
  MapWrapper.clear(_componentUIDs);
  _nextComponentUID = 0;
  MapWrapper.clear(_sharedStyleTexts);
  _lastInsertedStyleEl = null;
}
