library angular2.src.render.dom.shadow_dom.emulated_scoped_shadow_dom_strategy;

import "package:angular2/src/facade/lang.dart" show isBlank, isPresent;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/render/dom/shadow_dom/style_inliner.dart"
    show StyleInliner;
import "package:angular2/src/render/dom/shadow_dom/style_url_resolver.dart"
    show StyleUrlResolver;
import "emulated_unscoped_shadow_dom_strategy.dart"
    show EmulatedUnscopedShadowDomStrategy;
import "util.dart"
    show
        getContentAttribute,
        getHostAttribute,
        getComponentId,
        shimCssForComponent,
        insertStyleElement;

/**
 * This strategy emulates the Shadow DOM for the templates, styles **included**:
 * - components templates are added as children of their component element,
 * - both the template and the styles are modified so that styles are scoped to the component
 *   they belong to,
 * - styles are moved from the templates to the styleHost (i.e. the document head).
 *
 * Notes:
 * - styles are scoped to their component and will apply only to it,
 * - a common subset of shadow DOM selectors are supported,
 * - see `ShadowCss` for more information and limitations.
 */
class EmulatedScopedShadowDomStrategy
    extends EmulatedUnscopedShadowDomStrategy {
  StyleInliner styleInliner;
  EmulatedScopedShadowDomStrategy(
      StyleInliner styleInliner, StyleUrlResolver styleUrlResolver, styleHost)
      : super(styleUrlResolver, styleHost) {
    /* super call moved to initializer */;
    this.styleInliner = styleInliner;
  }
  Future processStyleElement(
      String hostComponentId, String templateUrl, styleEl) {
    var cssText = DOM.getText(styleEl);
    cssText = this.styleUrlResolver.resolveUrls(cssText, templateUrl);
    var css = this.styleInliner.inlineImports(cssText, templateUrl);
    if (PromiseWrapper.isPromise(css)) {
      DOM.setText(styleEl, "");
      return css.then((css) {
        css = shimCssForComponent(css, hostComponentId);
        DOM.setText(styleEl, css);
      });
    } else {
      css = shimCssForComponent(css, hostComponentId);
      DOM.setText(styleEl, css);
    }
    DOM.remove(styleEl);
    insertStyleElement(this.styleHost, styleEl);
    return null;
  }
  processElement(String hostComponentId, String elementComponentId, element) {
    // Shim the element as a child of the compiled component
    if (isPresent(hostComponentId)) {
      var contentAttribute =
          getContentAttribute(getComponentId(hostComponentId));
      DOM.setAttribute(element, contentAttribute, "");
    }
    // If the current element is also a component, shim it as a host
    if (isPresent(elementComponentId)) {
      var hostAttribute = getHostAttribute(getComponentId(elementComponentId));
      DOM.setAttribute(element, hostAttribute, "");
    }
  }
}
