library angular2.test.render.dom.shadow_dom.content_tag_spec;

import "package:angular2/test_lib.dart"
    show describe, beforeEach, it, expect, ddescribe, iit, SpyObject, el, proxy;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/render/dom/shadow_dom/content_tag.dart"
    show Content;
import "package:angular2/src/render/dom/shadow_dom/light_dom.dart"
    show LightDom;

@proxy
class DummyLightDom extends SpyObject implements LightDom {
  noSuchMethod(m) {
    super.noSuchMethod(m);
  }
}
var _scriptStart = '''<script start=""></script>''';
var _scriptEnd = '''<script end=""></script>''';
main() {
  describe("Content", () {
    var parent;
    var content;
    beforeEach(() {
      parent = el('''<div>${ _scriptStart}${ _scriptEnd}''');
      content = DOM.firstChild(parent);
    });
    it("should insert the nodes", () {
      var c = new Content(content, "");
      c.init(null);
      c.insert([el("<a></a>"), el("<b></b>")]);
      expect(DOM.getInnerHTML(parent))
          .toEqual('''${ _scriptStart}<a></a><b></b>${ _scriptEnd}''');
    });
    it("should remove the nodes from the previous insertion", () {
      var c = new Content(content, "");
      c.init(null);
      c.insert([el("<a></a>")]);
      c.insert([el("<b></b>")]);
      expect(DOM.getInnerHTML(parent))
          .toEqual('''${ _scriptStart}<b></b>${ _scriptEnd}''');
    });
    it("should insert empty list", () {
      var c = new Content(content, "");
      c.init(null);
      c.insert([el("<a></a>")]);
      c.insert([]);
      expect(DOM.getInnerHTML(parent))
          .toEqual('''${ _scriptStart}${ _scriptEnd}''');
    });
  });
}
