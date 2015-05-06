library angular2.test.core.compiler.view_manager_spec;

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
import "package:angular2/di.dart" show Injector, bind;
import "package:angular2/src/facade/lang.dart"
    show IMPLEMENTS, isBlank, isPresent;
import "package:angular2/src/facade/collection.dart"
    show MapWrapper, ListWrapper, StringMapWrapper;
import "package:angular2/src/core/compiler/view.dart"
    show AppProtoView, AppView, AppViewContainer;
import "package:angular2/src/core/compiler/view_ref.dart"
    show ProtoViewRef, ViewRef, internalView;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;
import "package:angular2/src/render/api.dart"
    show Renderer, RenderViewRef, RenderProtoViewRef, RenderViewContainerRef;
import "package:angular2/src/core/compiler/element_binder.dart"
    show ElementBinder;
import "package:angular2/src/core/compiler/element_injector.dart"
    show DirectiveBinding, ElementInjector;
import "package:angular2/src/core/compiler/directive_metadata_reader.dart"
    show DirectiveMetadataReader;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/compiler/view_manager.dart"
    show AppViewManager;
import "package:angular2/src/core/compiler/view_manager_utils.dart"
    show AppViewManagerUtils;
import "package:angular2/src/core/compiler/view_pool.dart" show AppViewPool;

main() {
  // TODO(tbosch): add missing tests
  describe("AppViewManager", () {
    var renderer;
    var utils;
    var viewPool;
    var manager;
    var reader;
    var createdViews;
    var createdRenderViews;
    ProtoViewRef wrapPv(AppProtoView protoView) {
      return new ProtoViewRef(protoView);
    }
    ViewRef wrapView(AppView view) {
      return new ViewRef(view);
    }
    elementRef(parentView, boundElementIndex) {
      return new ElementRef(parentView, boundElementIndex);
    }
    createDirectiveBinding(type) {
      var meta = reader.read(type);
      return DirectiveBinding.createFromType(meta.type, meta.annotation);
    }
    createEmptyElBinder() {
      return new ElementBinder(0, null, 0, null, null);
    }
    createComponentElBinder([nestedProtoView = null]) {
      var binding = createDirectiveBinding(SomeComponent);
      var binder = new ElementBinder(0, null, 0, null, binding);
      binder.nestedProtoView = nestedProtoView;
      return binder;
    }
    createProtoView([binders = null]) {
      if (isBlank(binders)) {
        binders = [];
      }
      var staticChildComponentCount = 0;
      for (var i = 0; i < binders.length; i++) {
        if (binders[i].hasStaticComponent()) {
          staticChildComponentCount++;
        }
      }
      var res = new AppProtoView(
          new MockProtoViewRef(staticChildComponentCount), null, null, null,
          null);
      res.elementBinders = binders;
      return res;
    }
    createElementInjector() {
      return SpyObject.stub(new SpyElementInjector(), {
        "isExportingComponent": false,
        "isExportingElement": false,
        "getEventEmitterAccessors": [],
        "getComponent": null
      }, {});
    }
    createView([pv = null]) {
      if (isBlank(pv)) {
        pv = createProtoView();
      }
      var view = new AppView(renderer, pv, MapWrapper.create());
      var elementInjectors =
          ListWrapper.createFixedSize(pv.elementBinders.length);
      for (var i = 0; i < pv.elementBinders.length; i++) {
        elementInjectors[i] = createElementInjector();
      }
      view.init(null, elementInjectors, [],
          ListWrapper.createFixedSize(pv.elementBinders.length),
          ListWrapper.createFixedSize(pv.elementBinders.length));
      return view;
    }
    beforeEach(() {
      reader = new DirectiveMetadataReader();
      renderer = new SpyRenderer();
      utils = new SpyAppViewManagerUtils();
      viewPool = new SpyAppViewPool();
      manager = new AppViewManager(viewPool, utils, renderer);
      createdViews = [];
      createdRenderViews = [];
      utils.spy("createView").andCallFake((proto, _a, _b) {
        var view = createView(proto);
        ListWrapper.push(createdViews, view);
        return view;
      });
      utils
          .spy("attachComponentView")
          .andCallFake((hostView, elementIndex, childView) {
        hostView.componentChildViews[elementIndex] = childView;
      });
      utils
          .spy("attachViewInContainer")
          .andCallFake((parentView, elementIndex, atIndex, childView) {
        var viewContainer = parentView.viewContainers[elementIndex];
        if (isBlank(viewContainer)) {
          viewContainer = new AppViewContainer();
          parentView.viewContainers[elementIndex] = viewContainer;
        }
        ListWrapper.insert(viewContainer.views, atIndex, childView);
      });
      var createRenderViewRefs = (renderPvRef) {
        var res = [];
        for (var i = 0; i < renderPvRef.nestedComponentCount + 1; i++) {
          var renderViewRef = new RenderViewRef();
          ListWrapper.push(res, renderViewRef);
          ListWrapper.push(createdRenderViews, renderViewRef);
        }
        return res;
      };
      renderer
          .spy("createDynamicComponentView")
          .andCallFake((_a, _b, childPvRef) {
        return createRenderViewRefs(childPvRef);
      });
      renderer.spy("createInPlaceHostView").andCallFake((_a, _b, childPvRef) {
        return createRenderViewRefs(childPvRef);
      });
      renderer.spy("createViewInContainer").andCallFake((_a, _b, childPvRef) {
        return createRenderViewRefs(childPvRef);
      });
    });
    describe("createDynamicComponentView", () {
      describe("basic functionality", () {
        var hostView, componentProtoView;
        beforeEach(() {
          hostView =
              createView(createProtoView([createComponentElBinder(null)]));
          hostView.render = new RenderViewRef();
          componentProtoView = createProtoView();
        });
        it("should create the view", () {
          expect(internalView(manager.createDynamicComponentView(
              elementRef(wrapView(hostView), 0), wrapPv(componentProtoView),
              null, null))).toBe(createdViews[0]);
          expect(createdViews[0].proto).toBe(componentProtoView);
        });
        it("should get the view from the pool", () {
          var createdView;
          viewPool.spy("getView").andCallFake((protoView) {
            createdView = createView(protoView);
            return createdView;
          });
          expect(internalView(manager.createDynamicComponentView(
              elementRef(wrapView(hostView), 0), wrapPv(componentProtoView),
              null, null))).toBe(createdView);
          expect(utils.spy("createView")).not.toHaveBeenCalled();
        });
        it("should attach the view", () {
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), null, null);
          expect(utils.spy("attachComponentView")).toHaveBeenCalledWith(
              hostView, 0, createdViews[0]);
        });
        it("should hydrate the dynamic component", () {
          var injector = new Injector([], null, false);
          var componentBinding = bind(SomeComponent).toClass(SomeComponent);
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), componentBinding, injector);
          expect(utils.spy("hydrateDynamicComponentInElementInjector"))
              .toHaveBeenCalledWith(hostView, 0, componentBinding, injector);
        });
        it("should hydrate the view", () {
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), null, null);
          expect(utils.spy("hydrateComponentView")).toHaveBeenCalledWith(
              hostView, 0);
        });
        it("should create and set the render view", () {
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), null, null);
          expect(renderer.spy("createDynamicComponentView"))
              .toHaveBeenCalledWith(
                  hostView.render, 0, componentProtoView.render);
          expect(createdViews[0].render).toBe(createdRenderViews[0]);
        });
        it("should set the event dispatcher", () {
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), null, null);
          var cmpView = createdViews[0];
          expect(renderer.spy("setEventDispatcher")).toHaveBeenCalledWith(
              cmpView.render, cmpView);
        });
      });
      describe("error cases", () {
        it("should not allow to use non component indices", () {
          var hostView = createView(createProtoView([createEmptyElBinder()]));
          var componentProtoView = createProtoView();
          expect(() => manager.createDynamicComponentView(
                  elementRef(wrapView(hostView), 0), wrapPv(componentProtoView),
                  null, null)).toThrowError(
              "There is no dynamic component directive at element 0");
        });
        it("should not allow to use static component indices", () {
          var hostView = createView(
              createProtoView([createComponentElBinder(createProtoView())]));
          var componentProtoView = createProtoView();
          expect(() => manager.createDynamicComponentView(
                  elementRef(wrapView(hostView), 0), wrapPv(componentProtoView),
                  null, null)).toThrowError(
              "There is no dynamic component directive at element 0");
        });
      });
      describe("recursively destroy dynamic child component views", () {});
    });
    describe("static child components", () {
      describe("recursively create when not cached", () {
        var hostView, componentProtoView, nestedProtoView;
        beforeEach(() {
          hostView =
              createView(createProtoView([createComponentElBinder(null)]));
          hostView.render = new RenderViewRef();
          nestedProtoView = createProtoView();
          componentProtoView =
              createProtoView([createComponentElBinder(nestedProtoView)]);
        });
        it("should create the view", () {
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), null, null);
          expect(createdViews[0].proto).toBe(componentProtoView);
          expect(createdViews[1].proto).toBe(nestedProtoView);
        });
        it("should hydrate the view", () {
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), null, null);
          expect(utils.spy("hydrateComponentView")).toHaveBeenCalledWith(
              createdViews[0], 0);
        });
        it("should set the render view", () {
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), null, null);
          expect(createdViews[1].render).toBe(createdRenderViews[1]);
        });
        it("should set the event dispatcher", () {
          manager.createDynamicComponentView(elementRef(wrapView(hostView), 0),
              wrapPv(componentProtoView), null, null);
          var cmpView = createdViews[1];
          expect(renderer.spy("setEventDispatcher")).toHaveBeenCalledWith(
              cmpView.render, cmpView);
        });
      });
      describe("recursively hydrate when getting from from the cache", () {});
      describe("recursively dehydrate", () {});
    });
    describe("createInPlaceHostView", () {
      // Note: We don't add tests for recursion or viewpool here as we assume that
      // this is using the same mechanism as the other methods...
      describe("basic functionality", () {
        var parentHostView, parentView, hostProtoView;
        beforeEach(() {
          parentHostView =
              createView(createProtoView([createComponentElBinder(null)]));
          parentView = createView();
          utils.attachComponentView(parentHostView, 0, parentView);
          parentView.render = new RenderViewRef();
          hostProtoView = createProtoView([createComponentElBinder(null)]);
        });
        it("should create the view", () {
          expect(internalView(manager.createInPlaceHostView(
              elementRef(wrapView(parentHostView), 0), null,
              wrapPv(hostProtoView), null))).toBe(createdViews[0]);
          expect(createdViews[0].proto).toBe(hostProtoView);
        });
        it("should attachAndHydrate the view", () {
          var injector = new Injector([], null, false);
          manager.createInPlaceHostView(elementRef(wrapView(parentHostView), 0),
              null, wrapPv(hostProtoView), injector);
          expect(utils.spy("attachAndHydrateInPlaceHostView"))
              .toHaveBeenCalledWith(
                  parentHostView, 0, createdViews[0], injector);
        });
        it("should create and set the render view", () {
          var elementOrSelector = "someSelector";
          manager.createInPlaceHostView(elementRef(wrapView(parentHostView), 0),
              elementOrSelector, wrapPv(hostProtoView), null);
          expect(renderer.spy("createInPlaceHostView")).toHaveBeenCalledWith(
              parentView.render, elementOrSelector, hostProtoView.render);
          expect(createdViews[0].render).toBe(createdRenderViews[0]);
        });
        it("should set the event dispatcher", () {
          manager.createInPlaceHostView(elementRef(wrapView(parentHostView), 0),
              null, wrapPv(hostProtoView), null);
          var cmpView = createdViews[0];
          expect(renderer.spy("setEventDispatcher")).toHaveBeenCalledWith(
              cmpView.render, cmpView);
        });
      });
    });
    describe("destroyInPlaceHostView", () {
      describe("basic functionality", () {
        var parentHostView,
            parentView,
            hostProtoView,
            hostView,
            hostRenderViewRef;
        beforeEach(() {
          parentHostView =
              createView(createProtoView([createComponentElBinder(null)]));
          parentView = createView();
          utils.attachComponentView(parentHostView, 0, parentView);
          parentView.render = new RenderViewRef();
          hostProtoView = createProtoView([createComponentElBinder(null)]);
          hostView = internalView(manager.createInPlaceHostView(
              elementRef(wrapView(parentHostView), 0), null,
              wrapPv(hostProtoView), null));
          hostRenderViewRef = hostView.render;
        });
        it("should dehydrate", () {
          manager.destroyInPlaceHostView(
              elementRef(wrapView(parentHostView), 0), wrapView(hostView));
          expect(utils.spy("detachInPlaceHostView")).toHaveBeenCalledWith(
              parentView, hostView);
        });
        it("should detach", () {
          manager.destroyInPlaceHostView(
              elementRef(wrapView(parentHostView), 0), wrapView(hostView));
          expect(utils.spy("dehydrateView")).toHaveBeenCalledWith(hostView);
        });
        it("should destroy and clear the render view", () {
          manager.destroyInPlaceHostView(
              elementRef(wrapView(parentHostView), 0), wrapView(hostView));
          expect(renderer.spy("destroyInPlaceHostView")).toHaveBeenCalledWith(
              parentView.render, hostRenderViewRef);
          expect(hostView.render).toBe(null);
        });
        it("should return the view to the pool", () {
          manager.destroyInPlaceHostView(
              elementRef(wrapView(parentHostView), 0), wrapView(hostView));
          expect(viewPool.spy("returnView")).toHaveBeenCalledWith(hostView);
        });
      });
      describe("recursively destroy inPlaceHostViews", () {});
    });
    describe("createViewInContainer", () {
      describe("basic functionality", () {
        var parentView, childProtoView;
        beforeEach(() {
          parentView = createView(createProtoView([createEmptyElBinder()]));
          parentView.render = new RenderViewRef();
          childProtoView = createProtoView();
        });
        it("should create a ViewContainerRef if not yet existing", () {
          manager.createViewInContainer(elementRef(wrapView(parentView), 0), 0,
              wrapPv(childProtoView), null);
          expect(parentView.viewContainers[0]).toBeTruthy();
        });
        it("should create the view", () {
          expect(internalView(manager.createViewInContainer(
              elementRef(wrapView(parentView), 0), 0, wrapPv(childProtoView),
              null))).toBe(createdViews[0]);
          expect(createdViews[0].proto).toBe(childProtoView);
        });
        it("should attach the view", () {
          manager.createViewInContainer(elementRef(wrapView(parentView), 0), 0,
              wrapPv(childProtoView), null);
          expect(utils.spy("attachViewInContainer")).toHaveBeenCalledWith(
              parentView, 0, 0, createdViews[0]);
        });
        it("should hydrate the view", () {
          var injector = new Injector([], null, false);
          manager.createViewInContainer(elementRef(wrapView(parentView), 0), 0,
              wrapPv(childProtoView), injector);
          expect(utils.spy("hydrateViewInContainer")).toHaveBeenCalledWith(
              parentView, 0, 0, injector);
        });
        it("should create and set the render view", () {
          manager.createViewInContainer(elementRef(wrapView(parentView), 0), 0,
              wrapPv(childProtoView), null);
          expect(renderer.spy("createViewInContainer")).toHaveBeenCalledWith(
              new RenderViewContainerRef(parentView.render, 0), 0,
              childProtoView.render);
          expect(createdViews[0].render).toBe(createdRenderViews[0]);
        });
        it("should set the event dispatcher", () {
          manager.createViewInContainer(elementRef(wrapView(parentView), 0), 0,
              wrapPv(childProtoView), null);
          var childView = createdViews[0];
          expect(renderer.spy("setEventDispatcher")).toHaveBeenCalledWith(
              childView.render, childView);
        });
      });
    });
    describe("destroyViewInContainer", () {
      describe("basic functionality", () {
        var parentView, childProtoView, childView;
        beforeEach(() {
          parentView = createView(createProtoView([createEmptyElBinder()]));
          parentView.render = new RenderViewRef();
          childProtoView = createProtoView();
          childView = internalView(manager.createViewInContainer(
              elementRef(wrapView(parentView), 0), 0, wrapPv(childProtoView),
              null));
        });
        it("should dehydrate", () {
          manager.destroyViewInContainer(
              elementRef(wrapView(parentView), 0), 0);
          expect(utils.spy("dehydrateView"))
              .toHaveBeenCalledWith(parentView.viewContainers[0].views[0]);
        });
        it("should detach", () {
          manager.destroyViewInContainer(
              elementRef(wrapView(parentView), 0), 0);
          expect(utils.spy("detachViewInContainer")).toHaveBeenCalledWith(
              parentView, 0, 0);
        });
        it("should destroy and clear the render view", () {
          manager.destroyViewInContainer(
              elementRef(wrapView(parentView), 0), 0);
          expect(renderer.spy("destroyViewInContainer")).toHaveBeenCalledWith(
              new RenderViewContainerRef(parentView.render, 0), 0);
          expect(childView.render).toBe(null);
        });
        it("should return the view to the pool", () {
          manager.destroyViewInContainer(
              elementRef(wrapView(parentView), 0), 0);
          expect(viewPool.spy("returnView")).toHaveBeenCalledWith(childView);
        });
      });
      describe("recursively destroy views in ViewContainers", () {
        var parentView, childProtoView, childView;
        beforeEach(() {
          parentView = createView(createProtoView([createEmptyElBinder()]));
          parentView.render = new RenderViewRef();
          childProtoView = createProtoView();
          childView = internalView(manager.createViewInContainer(
              elementRef(wrapView(parentView), 0), 0, wrapPv(childProtoView),
              null));
        });
        it("should dehydrate", () {
          manager.destroyInPlaceHostView(null, wrapView(parentView));
          expect(utils.spy("dehydrateView"))
              .toHaveBeenCalledWith(parentView.viewContainers[0].views[0]);
        });
        it("should detach", () {
          manager.destroyInPlaceHostView(null, wrapView(parentView));
          expect(utils.spy("detachViewInContainer")).toHaveBeenCalledWith(
              parentView, 0, 0);
        });
        it("should not destroy but clear the render view", () {
          manager.destroyInPlaceHostView(null, wrapView(parentView));
          expect(renderer.spy("destroyViewInContainer")).not.toHaveBeenCalled();
          expect(childView.render).toBe(null);
        });
        it("should return the view to the pool", () {
          manager.destroyInPlaceHostView(null, wrapView(parentView));
          expect(viewPool.spy("returnView")).toHaveBeenCalledWith(childView);
        });
      });
    });
    describe("attachViewInContainer", () {});
    describe("detachViewInContainer", () {});
  });
}
class MockProtoViewRef extends RenderProtoViewRef {
  num nestedComponentCount;
  MockProtoViewRef(num nestedComponentCount) : super() {
    /* super call moved to initializer */;
    this.nestedComponentCount = nestedComponentCount;
  }
}
@Component(selector: "someComponent")
class SomeComponent {}
@proxy
@IMPLEMENTS(Renderer)
class SpyRenderer extends SpyObject implements Renderer {
  SpyRenderer() : super(Renderer) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@proxy
@IMPLEMENTS(AppViewPool)
class SpyAppViewPool extends SpyObject implements AppViewPool {
  SpyAppViewPool() : super(AppViewPool) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@proxy
@IMPLEMENTS(AppViewManagerUtils)
class SpyAppViewManagerUtils extends SpyObject implements AppViewManagerUtils {
  SpyAppViewManagerUtils() : super(AppViewManagerUtils) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@proxy
@IMPLEMENTS(ElementInjector)
class SpyElementInjector extends SpyObject implements ElementInjector {
  SpyElementInjector() : super(ElementInjector) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
