library angular2.test.render.dom.shadow_dom.native_shadow_dom_strategy_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        describe,
        el,
        expect,
        iit,
        inject,
        it,
        xit,
        SpyObject;
import "package:angular2/src/render/dom/shadow_dom/native_shadow_dom_strategy.dart"
    show NativeShadowDomStrategy;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/render/dom/shadow_dom/style_url_resolver.dart"
    show StyleUrlResolver;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;

main() {
  var strategy;
  describe("NativeShadowDomStrategy", () {
    beforeEach(() {
      var urlResolver = new UrlResolver();
      var styleUrlResolver = new StyleUrlResolver(urlResolver);
      strategy = new NativeShadowDomStrategy(styleUrlResolver);
    });
    it("should use the native shadow root", () {
      var host = el("<div><span>original content</span></div>");
      expect(strategy.prepareShadowRoot(host)).toBe(DOM.getShadowRoot(host));
    });
    it("should rewrite style urls", () {
      var styleElement =
          el("<style>.foo {background-image: url(\"img.jpg\");}</style>");
      strategy.processStyleElement(
          "someComponent", "http://base", styleElement);
      expect(styleElement).toHaveText(
          ".foo {" + "background-image: url('http://base/img.jpg');" + "}");
    });
    it("should not inline import rules", () {
      var styleElement = el("<style>@import \"other.css\";</style>");
      strategy.processStyleElement(
          "someComponent", "http://base", styleElement);
      expect(styleElement).toHaveText("@import 'http://base/other.css';");
    });
  });
}
