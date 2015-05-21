library angular2.src.dom.generic_browser_adapter;

import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent, isFunction;
import "dom_adapter.dart" show DomAdapter;

/**
 * Provides DOM operations in any browser environment.
 */
class GenericBrowserDomAdapter extends DomAdapter {
  getDistributedNodes(el) {
    return el.getDistributedNodes();
  }
  resolveAndSetHref(el, String baseUrl, String href) {
    el.href = href == null ? baseUrl : baseUrl + "/../" + href;
  }
  List<dynamic> cssToRules(String css) {
    var style = this.createStyleElement(css);
    this.appendChild(this.defaultDoc().head, style);
    var rules = ListWrapper.create();
    if (isPresent(style.sheet)) {
      // TODO(sorvell): Firefox throws when accessing the rules of a stylesheet

      // with an @import

      // https://bugzilla.mozilla.org/show_bug.cgi?id=625013
      try {
        var rawRules = style.sheet.cssRules;
        rules = ListWrapper.createFixedSize(rawRules.length);
        for (var i = 0; i < rawRules.length; i++) {
          rules[i] = rawRules[i];
        }
      } catch (e, e_stack) {}
    } else {}
    this.remove(style);
    return rules;
  }
  bool supportsDOMEvents() {
    return true;
  }
  bool supportsNativeShadowDOM() {
    return isFunction(this.defaultDoc().body.createShadowRoot);
  }
}
