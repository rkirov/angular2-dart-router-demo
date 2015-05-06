library angular2.test.render.dom.view.view_hydrator_spec;

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
import "package:angular2/src/facade/lang.dart"
    show IMPLEMENTS, isBlank, isPresent;
import "package:angular2/src/render/dom/view/proto_view.dart"
    show RenderProtoView;
import "package:angular2/src/render/dom/view/element_binder.dart"
    show ElementBinder;
import "package:angular2/src/render/dom/view/view.dart" show RenderView;
import "package:angular2/src/render/dom/shadow_dom/shadow_dom_strategy.dart"
    show ShadowDomStrategy;
import "package:angular2/src/render/dom/shadow_dom/light_dom.dart"
    show LightDom;
import "package:angular2/src/render/dom/events/event_manager.dart"
    show EventManager;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/render/dom/view/view_factory.dart"
    show ViewFactory;
import "package:angular2/src/render/dom/view/view_hydrator.dart"
    show RenderViewHydrator;

main() {
  describe("RenderViewHydrator", () {
    var shadowDomStrategy;
    var eventManager;
    var viewFactory;
    var viewHydrator;
    createProtoView({rootEl, binders}) {
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
    createHostProtoView(nestedProtoView) {
      return createProtoView(
          binders: [createComponentElBinder("someComponent", nestedProtoView)]);
    }
    createEmptyView() {
      var root = el("<div><div></div></div>");
      return new RenderView(
          createProtoView(), [DOM.childNodes(root)[0]], [], [], []);
    }
    createHostView(pv, shadowDomView) {
      var view = new RenderView(
          pv, [el("<div></div>")], [], [el("<div></div>")], [null]);
      ViewFactory.setComponentView(shadowDomStrategy, view, 0, shadowDomView);
      return view;
    }
    hydrate(view) {
      viewHydrator.hydrateInPlaceHostView(null, view);
    }
    dehydrate(view) {
      viewHydrator.dehydrateInPlaceHostView(null, view);
    }
    beforeEach(() {
      eventManager = new SpyEventManager();
      shadowDomStrategy = new SpyShadowDomStrategy();
      shadowDomStrategy
          .spy("constructLightDom")
          .andCallFake((lightDomView, shadowDomView, el) {
        return new SpyLightDom();
      });
      viewFactory = new SpyViewFactory();
      viewHydrator =
          new RenderViewHydrator(eventManager, viewFactory, shadowDomStrategy);
    });
    describe("hydrateDynamicComponentView", () {
      it("should redistribute", () {
        var shadowView = createEmptyView();
        var hostPv = createHostProtoView(createProtoView());
        var hostView = createHostView(hostPv, shadowView);
        viewHydrator.hydrateDynamicComponentView(hostView, 0, shadowView);
        SpyLightDom lightDomSpy = hostView.lightDoms[0];
        expect(lightDomSpy.spy("redistribute")).toHaveBeenCalled();
      });
    });
    describe("hydrateInPlaceHostView", () {
      createInPlaceHostView() {
        var hostPv = createHostProtoView(createProtoView());
        var shadowView = createEmptyView();
        return createHostView(hostPv, shadowView);
      }
      it("should hydrate the view", () {
        var hostView = createInPlaceHostView();
        viewHydrator.hydrateInPlaceHostView(null, hostView);
        expect(hostView.hydrated).toBe(true);
      });
      it("should store the view in the parent view", () {
        var parentView = createEmptyView();
        var hostView = createInPlaceHostView();
        viewHydrator.hydrateInPlaceHostView(parentView, hostView);
        expect(parentView.imperativeHostViews).toEqual([hostView]);
      });
    });
    describe("dehydrateInPlaceHostView", () {
      createAndHydrateInPlaceHostView(parentView) {
        var hostPv = createHostProtoView(createProtoView());
        var shadowView = createEmptyView();
        var hostView = createHostView(hostPv, shadowView);
        viewHydrator.hydrateInPlaceHostView(parentView, hostView);
        return hostView;
      }
      it("should clear the host view", () {
        var parentView = createEmptyView();
        var hostView = createAndHydrateInPlaceHostView(parentView);
        var rootNodes = hostView.rootNodes;
        expect(rootNodes[0].parentNode).toBeTruthy();
        viewHydrator.dehydrateInPlaceHostView(parentView, hostView);
        expect(parentView.imperativeHostViews).toEqual([]);
        expect(rootNodes[0].parentNode).toBeFalsy();
        expect(hostView.rootNodes).toEqual([]);
      });
    });
    describe("hydrate... shared functionality", () {
      it("should hydrate existing child components", () {
        var hostPv = createHostProtoView(createProtoView());
        var shadowView = createEmptyView();
        createHostView(hostPv, shadowView);
        hydrate(shadowView);
        expect(shadowView.hydrated).toBe(true);
      });
    });
    describe("dehydrate... shared functionality", () {
      var hostView;
      createAndHydrate(nestedProtoView, shadowView,
          [imperativeHostView = null]) {
        var hostPv = createHostProtoView(nestedProtoView);
        hostView = createHostView(hostPv, shadowView);
        if (isPresent(imperativeHostView)) {
          viewHydrator.hydrateInPlaceHostView(hostView, imperativeHostView);
        }
        hydrate(hostView);
      }
      it("should dehydrate child components", () {
        var shadowView = createEmptyView();
        createAndHydrate(createProtoView(), shadowView);
        expect(shadowView.hydrated).toBe(true);
        dehydrate(hostView);
        expect(shadowView.hydrated).toBe(false);
      });
      it("should not clear static child components", () {
        var shadowView = createEmptyView();
        createAndHydrate(createProtoView(), shadowView);
        dehydrate(hostView);
        expect(hostView.componentChildViews[0]).toBe(shadowView);
        expect(shadowView.rootNodes[0].parentNode).toBeTruthy();
        expect(viewFactory.spy("returnView")).not.toHaveBeenCalled();
      });
      it("should clear dynamic child components", () {
        var shadowView = createEmptyView();
        createAndHydrate(null, shadowView);
        expect(shadowView.rootNodes[0].parentNode).toBeTruthy();
        dehydrate(hostView);
        expect(hostView.componentChildViews[0]).toBe(null);
        expect(shadowView.rootNodes[0].parentNode).toBe(null);
        expect(viewFactory.spy("returnView")).toHaveBeenCalledWith(shadowView);
      });
      it("should clear views in ViewContainers", () {
        createAndHydrate(null, null);
        var vc = hostView.getOrCreateViewContainer(0);
        var childView = createEmptyView();
        vc.insert(childView);
        dehydrate(hostView);
        expect(viewFactory.spy("returnView")).toHaveBeenCalledWith(childView);
      });
      it("should clear imperatively added child components", () {
        var shadowView = createEmptyView();
        createAndHydrate(createProtoView(), shadowView);
        var impHostView = createHostView(
            createHostProtoView(createProtoView()), createEmptyView());
        shadowView.imperativeHostViews = [impHostView];
        var rootNodes = impHostView.rootNodes;
        expect(rootNodes[0].parentNode).toBeTruthy();
        dehydrate(hostView);
        expect(shadowView.imperativeHostViews).toEqual([]);
        expect(impHostView.rootNodes).toEqual([]);
        expect(rootNodes[0].parentNode).toBeFalsy();
        expect(viewFactory.spy("returnView")).toHaveBeenCalledWith(impHostView);
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
@proxy
@IMPLEMENTS(ViewFactory)
class SpyViewFactory extends SpyObject implements ViewFactory {
  SpyViewFactory() : super(ViewFactory) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
