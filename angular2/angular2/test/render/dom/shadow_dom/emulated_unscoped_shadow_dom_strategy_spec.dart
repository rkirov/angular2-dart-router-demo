library angular2.test.render.dom.shadow_dom.emulated_unscoped_shadow_dom_strategy_spec;

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
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, ListWrapper;
import "package:angular2/src/render/dom/shadow_dom/emulated_unscoped_shadow_dom_strategy.dart"
    show EmulatedUnscopedShadowDomStrategy;
import "package:angular2/src/render/dom/shadow_dom/util.dart"
    show resetShadowDomCache;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/render/dom/shadow_dom/style_url_resolver.dart"
    show StyleUrlResolver;
import "package:angular2/src/render/dom/view/view.dart" show RenderView;

main() {
  var strategy;
  describe("EmulatedUnscopedShadowDomStrategy", () {
    var styleHost;
    beforeEach(() {
      var urlResolver = new UrlResolver();
      var styleUrlResolver = new StyleUrlResolver(urlResolver);
      styleHost = el("<div></div>");
      strategy =
          new EmulatedUnscopedShadowDomStrategy(styleUrlResolver, styleHost);
      resetShadowDomCache();
    });
    it("should attach the view nodes as child of the host element", () {
      var host = el("<div><span>original content</span></div>");
      var originalChild = DOM.childNodes(host)[0];
      var nodes = el("<div>view</div>");
      var view = new RenderView(null, [nodes], [], [], []);
      strategy.attachTemplate(host, view);
      expect(DOM.childNodes(host)[0]).toBe(originalChild);
      expect(DOM.childNodes(host)[1]).toBe(nodes);
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
    it("should move the style element to the style host", () {
      var compileElement = el("<div><style>.one {}</style></div>");
      var styleElement = DOM.firstChild(compileElement);
      strategy.processStyleElement(
          "someComponent", "http://base", styleElement);
      expect(compileElement).toHaveText("");
      expect(styleHost).toHaveText(".one {}");
    });
    it("should insert the same style only once in the style host", () {
      var styleEls = [
        el("<style>/*css1*/</style>"),
        el("<style>/*css2*/</style>"),
        el("<style>/*css1*/</style>")
      ];
      ListWrapper.forEach(styleEls, (styleEl) {
        strategy.processStyleElement("someComponent", "http://base", styleEl);
      });
      expect(styleHost).toHaveText("/*css1*//*css2*/");
    });
  });
}
