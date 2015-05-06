library angular2.src.render.dom.shadow_dom.emulated_unscoped_shadow_dom_strategy;

import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "../view/view.dart" as viewModule;
import "light_dom.dart" show LightDom;
import "shadow_dom_strategy.dart" show ShadowDomStrategy;
import "style_url_resolver.dart" show StyleUrlResolver;
import "util.dart" show moveViewNodesIntoParent;
import "util.dart"
    show
        insertSharedStyleText; /**
 * This strategy emulates the Shadow DOM for the templates, styles **excluded**:
 * - components templates are added as children of their component element,
 * - styles are moved from the templates to the styleHost (i.e. the document head).
 *
 * Notes:
 * - styles are **not** scoped to their component and will apply to the whole document,
 * - you can **not** use shadow DOM specific selectors in the styles
 */

class EmulatedUnscopedShadowDomStrategy extends ShadowDomStrategy {
  StyleUrlResolver styleUrlResolver;
  var styleHost;
  EmulatedUnscopedShadowDomStrategy(
      StyleUrlResolver styleUrlResolver, styleHost)
      : super() {
    /* super call moved to initializer */;
    this.styleUrlResolver = styleUrlResolver;
    this.styleHost = styleHost;
  }
  bool hasNativeContentElement() {
    return false;
  }
  attachTemplate(el, viewModule.RenderView view) {
    moveViewNodesIntoParent(el, view);
  }
  LightDom constructLightDom(viewModule.RenderView lightDomView,
      viewModule.RenderView shadowDomView, el) {
    return new LightDom(lightDomView, shadowDomView, el);
  }
  Future processStyleElement(
      String hostComponentId, String templateUrl, styleEl) {
    var cssText = DOM.getText(styleEl);
    cssText = this.styleUrlResolver.resolveUrls(cssText, templateUrl);
    DOM.setText(styleEl, cssText);
    DOM.remove(styleEl);
    insertSharedStyleText(cssText, this.styleHost, styleEl);
    return null;
  }
}
