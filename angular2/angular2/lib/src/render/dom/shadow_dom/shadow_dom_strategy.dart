library angular2.src.render.dom.shadow_dom.shadow_dom_strategy;

import "package:angular2/src/facade/lang.dart" show isBlank, isPresent;
import "package:angular2/src/facade/async.dart" show Future;
import "../view/view.dart" as viewModule;
import "light_dom.dart" show LightDom;

class ShadowDomStrategy {
  bool hasNativeContentElement() {
    return true;
  }
  attachTemplate(el, viewModule.RenderView view) {}
  LightDom constructLightDom(viewModule.RenderView lightDomView,
      viewModule.RenderView shadowDomView, el) {
    return null;
  } /**
   * An optional step that can modify the template style elements.
   */
  Future processStyleElement(
      String hostComponentId, String templateUrl, styleElement) {
    return null;
  } /**
   * An optional step that can modify the template elements (style elements exlcuded).
   */
  processElement(String hostComponentId, String elementComponentId, element) {}
}
