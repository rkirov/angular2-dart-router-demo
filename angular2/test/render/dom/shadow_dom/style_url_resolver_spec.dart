library angular2.test.render.dom.shadow_dom.style_url_resolver_spec;

import "package:angular2/test_lib.dart"
    show describe, it, expect, beforeEach, ddescribe, iit, xit, el;
import "package:angular2/src/render/dom/shadow_dom/style_url_resolver.dart"
    show StyleUrlResolver;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;

main() {
  describe("StyleUrlResolver", () {
    it("should resolve \"url()\" urls", () {
      var styleUrlResolver = new StyleUrlResolver(new FakeUrlResolver());
      var css = '''
      .foo {
        background-image: url("double.jpg");
        background-image: url(\'simple.jpg\');
        background-image: url(noquote.jpg);
      }''';
      var expectedCss = '''
      .foo {
        background-image: url(\'base/double.jpg\');
        background-image: url(\'base/simple.jpg\');
        background-image: url(\'base/noquote.jpg\');
      }''';
      var resolvedCss = styleUrlResolver.resolveUrls(css, "base");
      expect(resolvedCss).toEqual(expectedCss);
    });
    it("should resolve \"@import\" urls", () {
      var styleUrlResolver = new StyleUrlResolver(new FakeUrlResolver());
      var css = '''
      @import \'1.css\';
      @import "2.css";
      ''';
      var expectedCss = '''
      @import \'base/1.css\';
      @import \'base/2.css\';
      ''';
      var resolvedCss = styleUrlResolver.resolveUrls(css, "base");
      expect(resolvedCss).toEqual(expectedCss);
    });
    it("should resolve \"@import url()\" urls", () {
      var styleUrlResolver = new StyleUrlResolver(new FakeUrlResolver());
      var css = '''
      @import url(\'3.css\');
      @import url("4.css");
      @import url(5.css);
      ''';
      var expectedCss = '''
      @import url(\'base/3.css\');
      @import url(\'base/4.css\');
      @import url(\'base/5.css\');
      ''';
      var resolvedCss = styleUrlResolver.resolveUrls(css, "base");
      expect(resolvedCss).toEqual(expectedCss);
    });
    it("should support media query in \"@import\"", () {
      var styleUrlResolver = new StyleUrlResolver(new FakeUrlResolver());
      var css = '''
      @import \'print.css\' print;
      @import url(print.css) print;
      ''';
      var expectedCss = '''
      @import \'base/print.css\' print;
      @import url(\'base/print.css\') print;
      ''';
      var resolvedCss = styleUrlResolver.resolveUrls(css, "base");
      expect(resolvedCss).toEqual(expectedCss);
    });
  });
}
class FakeUrlResolver extends UrlResolver {
  String resolve(String baseUrl, String url) {
    return baseUrl + "/" + url;
  }
}
