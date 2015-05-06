library angular2.test.render.dom.view.view_factory_spec;

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
import "package:angular2/src/facade/lang.dart" show IMPLEMENTS, isBlank;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:angular2/src/render/dom/view/view_factory.dart"
    show ViewFactory;
import "package:angular2/src/render/dom/view/proto_view.dart"
    show RenderProtoView;
import "package:angular2/src/render/dom/view/view.dart" show RenderView;
import "package:angular2/src/render/dom/view/element_binder.dart"
    show ElementBinder;
import "package:angular2/src/render/dom/shadow_dom/shadow_dom_strategy.dart"
    show ShadowDomStrategy;
import "package:angular2/src/render/dom/shadow_dom/light_dom.dart"
    show LightDom;
import "package:angular2/src/render/dom/events/event_manager.dart"
    show EventManager;

main() {
  describe("RenderViewFactory", () {
    var eventManager;
    var shadowDomStrategy;
    ViewFactory createViewFactory({capacity}) {
      return new ViewFactory(capacity, eventManager, shadowDomStrategy);
    }
    createProtoView([rootEl = null, binders = null]) {
      if (isBlank(rootEl)) {
        rootEl = el("<div></div>");
      }
      if (isBlank(binders)) {
        binders = [];
      }
      return new RenderProtoView(element: rootEl, elementBinders: binders);
    }
    createComponentElBinder(componentId, [nestedProtoView = null]) {
      var binder =
          new ElementBinder(componentId: componentId, textNodeIndices: []);
      binder.nestedProtoView = nestedProtoView;
      return binder;
    }
    beforeEach(() {
      eventManager = new SpyEventManager();
      shadowDomStrategy = new SpyShadowDomStrategy();
    });
    it("should create views without cache", () {
      var pv = createProtoView();
      var vf = createViewFactory(capacity: 0);
      expect(vf.getView(pv) is RenderView).toBe(true);
    });
    describe("caching", () {
      it("should support multiple RenderProtoViews", () {
        var pv1 = createProtoView();
        var pv2 = createProtoView();
        var vf = createViewFactory(capacity: 2);
        var view1 = vf.getView(pv1);
        var view2 = vf.getView(pv2);
        vf.returnView(view1);
        vf.returnView(view2);
        expect(vf.getView(pv1)).toBe(view1);
        expect(vf.getView(pv2)).toBe(view2);
      });
      it("should reuse the newest view that has been returned", () {
        var pv = createProtoView();
        var vf = createViewFactory(capacity: 2);
        var view1 = vf.getView(pv);
        var view2 = vf.getView(pv);
        vf.returnView(view1);
        vf.returnView(view2);
        expect(vf.getView(pv)).toBe(view2);
      });
      it("should not add views when the capacity has been reached", () {
        var pv = createProtoView();
        var vf = createViewFactory(capacity: 2);
        var view1 = vf.getView(pv);
        var view2 = vf.getView(pv);
        var view3 = vf.getView(pv);
        vf.returnView(view1);
        vf.returnView(view2);
        vf.returnView(view3);
        expect(vf.getView(pv)).toBe(view2);
        expect(vf.getView(pv)).toBe(view1);
      });
    });
    describe("child components", () {
      var vf, log;
      beforeEach(() {
        vf = createViewFactory(capacity: 1);
        log = [];
        shadowDomStrategy.spy("attachTemplate").andCallFake((el, view) {
          ListWrapper.push(log, ["attachTemplate", el, view]);
        });
        shadowDomStrategy
            .spy("constructLightDom")
            .andCallFake((lightDomView, shadowDomView, el) {
          ListWrapper.push(
              log, ["constructLightDom", lightDomView, shadowDomView, el]);
          return new SpyLightDom();
        });
      });
      it("should create static child component views", () {
        var hostPv = createProtoView(
            el("<div><div class=\"ng-binding\"></div></div>"),
            [createComponentElBinder("someComponent", createProtoView())]);
        var hostView = vf.getView(hostPv);
        var shadowView = hostView.componentChildViews[0];
        expect(shadowView).toBeTruthy();
        expect(hostView.lightDoms[0]).toBeTruthy();
        expect(log[0]).toEqual([
          "constructLightDom",
          hostView,
          shadowView,
          hostView.boundElements[0]
        ]);
        expect(log[1])
            .toEqual(["attachTemplate", hostView.boundElements[0], shadowView]);
      });
      it("should not create dynamic child component views", () {
        var hostPv = createProtoView(
            el("<div><div class=\"ng-binding\"></div></div>"),
            [createComponentElBinder("someComponent", null)]);
        var hostView = vf.getView(hostPv);
        var shadowView = hostView.componentChildViews[0];
        expect(shadowView).toBeFalsy();
        expect(hostView.lightDoms[0]).toBeFalsy();
        expect(log).toEqual([]);
      });
    });
  });
}
@proxy
@IMPLEMENTS(EventManager)
class SpyEventManager extends SpyObject implements EventManager {
  SpyEventManager() : super(EventManager) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@proxy
@IMPLEMENTS(ShadowDomStrategy)
class SpyShadowDomStrategy extends SpyObject implements ShadowDomStrategy {
  SpyShadowDomStrategy() : super(ShadowDomStrategy) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@proxy
@IMPLEMENTS(LightDom)
class SpyLightDom extends SpyObject implements LightDom {
  SpyLightDom() : super(LightDom) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
