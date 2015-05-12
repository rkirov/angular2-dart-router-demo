library angular2.test.render.dom.view.view_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        xdescribe,
        describe,
        el,
        dispatchEvent,
        expect,
        iit,
        inject,
        beforeEachBindings,
        it,
        xit,
        SpyObject,
        proxy;
import "package:angular2/src/facade/lang.dart" show isBlank;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:angular2/src/render/dom/view/proto_view.dart" show DomProtoView;
import "package:angular2/src/render/dom/view/element_binder.dart"
    show ElementBinder;
import "package:angular2/src/render/dom/view/view.dart" show DomView;
import "package:angular2/src/render/dom/shadow_dom/light_dom.dart"
    show LightDom;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;

main() {
  describe("DomView", () {
    createProtoView([binders = null]) {
      if (isBlank(binders)) {
        binders = [];
      }
      var rootEl = el("<div></div>");
      return new DomProtoView(element: rootEl, elementBinders: binders);
    }
    createView([pv = null, boundElementCount = 0]) {
      if (isBlank(pv)) {
        pv = createProtoView();
      }
      var root = el("<div><div></div></div>");
      var boundElements = [];
      for (var i = 0; i < boundElementCount; i++) {
        ListWrapper.push(boundElements, el("<span></span"));
      }
      return new DomView(pv, [DOM.childNodes(root)[0]], [], boundElements, []);
    }
    describe("getDirectParentLightDom", () {
      it("should return the LightDom of the direct parent", () {
        var pv = createProtoView([
          new ElementBinder(),
          new ElementBinder(parentIndex: 0, distanceToParent: 1)
        ]);
        var view = createView(pv, 2);
        view.lightDoms[0] = new SpyLightDom();
        view.lightDoms[1] = new SpyLightDom();
        expect(view.getDirectParentLightDom(1)).toBe(view.lightDoms[0]);
      });
      it("should return null if the direct parent is not bound", () {
        var pv = createProtoView([
          new ElementBinder(),
          new ElementBinder(),
          new ElementBinder(parentIndex: 0, distanceToParent: 2)
        ]);
        var view = createView(pv, 3);
        view.lightDoms[0] = new SpyLightDom();
        view.lightDoms[1] = new SpyLightDom();
        view.lightDoms[2] = new SpyLightDom();
        expect(view.getDirectParentLightDom(2)).toBe(null);
      });
    });
  });
}
@proxy
class SpyLightDom extends SpyObject implements LightDom {
  SpyLightDom() : super(LightDom) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
