library angular2.test.render.dom.shadow_dom.style_inliner_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        beforeEachBindings,
        ddescribe,
        describe,
        el,
        expect,
        iit,
        inject,
        it,
        xit;
import "package:angular2/src/render/dom/shadow_dom/style_inliner.dart"
    show StyleInliner;
import "package:angular2/src/facade/lang.dart" show isBlank;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/collection.dart" show Map, MapWrapper;
import "package:angular2/src/services/xhr.dart" show XHR;
import "package:angular2/di.dart" show bind;

main() {
  describe("StyleInliner", () {
    beforeEachBindings(() => [bind(XHR).toClass(FakeXHR)]);
    describe("loading", () {
      it("should return a string when there is no import statement", inject(
          [StyleInliner], (inliner) {
        var css = ".main {}";
        var loadedCss = inliner.inlineImports(css, "http://base");
        expect(loadedCss).toEqual(css);
      }));
      it("should inline @import rules", inject([
        XHR,
        StyleInliner,
        AsyncTestCompleter
      ], (xhr, inliner, async) {
        xhr.reply("http://base/one.css", ".one {}");
        var css = "@import url(\"one.css\");.main {}";
        var loadedCss = inliner.inlineImports(css, "http://base");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css).toEqual(".one {}\n.main {}");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
      it("should support url([unquoted url]) in @import rules", inject([
        XHR,
        StyleInliner,
        AsyncTestCompleter
      ], (xhr, inliner, async) {
        xhr.reply("http://base/one.css", ".one {}");
        var css = "@import url(one.css);.main {}";
        var loadedCss = inliner.inlineImports(css, "http://base");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css).toEqual(".one {}\n.main {}");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
      it("should handle @import error gracefuly", inject([
        StyleInliner,
        AsyncTestCompleter
      ], (inliner, async) {
        var css = "@import \"one.css\";.main {}";
        var loadedCss = inliner.inlineImports(css, "http://base");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css)
              .toEqual("/* failed to import http://base/one.css */\n.main {}");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
      it("should inline multiple @import rules", inject([
        XHR,
        StyleInliner,
        AsyncTestCompleter
      ], (xhr, inliner, async) {
        xhr.reply("http://base/one.css", ".one {}");
        xhr.reply("http://base/two.css", ".two {}");
        var css = "@import \"one.css\";@import \"two.css\";.main {}";
        var loadedCss = inliner.inlineImports(css, "http://base");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css).toEqual(".one {}\n.two {}\n.main {}");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
      it("should inline nested @import rules", inject([
        XHR,
        StyleInliner,
        AsyncTestCompleter
      ], (xhr, inliner, async) {
        xhr.reply("http://base/one.css", "@import \"two.css\";.one {}");
        xhr.reply("http://base/two.css", ".two {}");
        var css = "@import \"one.css\";.main {}";
        var loadedCss = inliner.inlineImports(css, "http://base/");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css).toEqual(".two {}\n.one {}\n.main {}");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
      it("should handle circular dependencies gracefuly", inject([
        XHR,
        StyleInliner,
        AsyncTestCompleter
      ], (xhr, inliner, async) {
        xhr.reply("http://base/one.css", "@import \"two.css\";.one {}");
        xhr.reply("http://base/two.css", "@import \"one.css\";.two {}");
        var css = "@import \"one.css\";.main {}";
        var loadedCss = inliner.inlineImports(css, "http://base/");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css).toEqual(".two {}\n.one {}\n.main {}");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
      it("should handle invalid @import fracefuly", inject([
        StyleInliner,
        AsyncTestCompleter
      ], (inliner, async) {
        // Invalid rule: the url is not quoted
        var css = "@import one.css;.main {}";
        var loadedCss = inliner.inlineImports(css, "http://base/");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css).toEqual(
              "/* Invalid import rule: \"@import one.css;\" */.main {}");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
    });
    describe("media query", () {
      it("should wrap inlined content in media query", inject([
        XHR,
        StyleInliner,
        AsyncTestCompleter
      ], (xhr, inliner, async) {
        xhr.reply("http://base/one.css", ".one {}");
        var css =
            "@import \"one.css\" (min-width: 700px) and (orientation: landscape);";
        var loadedCss = inliner.inlineImports(css, "http://base/");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css).toEqual(
              "@media (min-width: 700px) and (orientation: landscape) {\n.one {}\n}\n");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
    });
    describe("url rewritting", () {
      it("should rewrite url in inlined content", inject([
        XHR,
        StyleInliner,
        AsyncTestCompleter
      ], (xhr, inliner, async) {
        // it should rewrite both '@import' and 'url()'
        xhr.reply("http://base/one.css",
            "@import \"./nested/two.css\";.one {background-image: url(\"one.jpg\");}");
        xhr.reply("http://base/nested/two.css",
            ".two {background-image: url(\"../img/two.jpg\");}");
        var css = "@import \"one.css\";";
        var loadedCss = inliner.inlineImports(css, "http://base/");
        expect(loadedCss).toBePromise();
        PromiseWrapper.then(loadedCss, (css) {
          expect(css).toEqual(
              ".two {background-image: url('http://base/img/two.jpg');}\n" +
                  ".one {background-image: url('http://base/one.jpg');}\n");
          async.done();
        }, (e) {
          throw "fail;";
        });
      }));
    });
  });
}
class FakeXHR extends XHR {
  Map _responses;
  FakeXHR() : super() {
    /* super call moved to initializer */;
    this._responses = MapWrapper.create();
  }
  Future<String> get(String url) {
    var response = MapWrapper.get(this._responses, url);
    if (isBlank(response)) {
      return PromiseWrapper.reject("xhr error", null);
    }
    return PromiseWrapper.resolve(response);
  }
  reply(String url, String response) {
    MapWrapper.set(this._responses, url, response);
  }
}
