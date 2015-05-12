library angular2.test.core.compiler.view_manager_utils_spec;

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
        proxy,
        Log;
import "package:angular2/di.dart" show Injector, bind;
import "package:angular2/src/facade/lang.dart" show isBlank, isPresent;
import "package:angular2/src/facade/collection.dart"
    show MapWrapper, ListWrapper, StringMapWrapper;
import "package:angular2/src/core/compiler/view.dart"
    show AppProtoView, AppView;
import "package:angular2/change_detection.dart" show ChangeDetector;
import "package:angular2/src/core/compiler/element_binder.dart"
    show ElementBinder;
import "package:angular2/src/core/compiler/element_injector.dart"
    show DirectiveBinding, ElementInjector, PreBuiltObjects;
import "package:angular2/src/core/compiler/directive_metadata_reader.dart"
    show DirectiveMetadataReader;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/compiler/view_manager_utils.dart"
    show AppViewManagerUtils;

main() {
  // TODO(tbosch): add more tests here!
  describe("AppViewManagerUtils", () {
    var metadataReader;
    var utils;
    createInjector() {
      return new Injector([], null, false);
    }
    createDirectiveBinding(type) {
      var meta = metadataReader.read(type);
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
      var res = new AppProtoView(null, null, null, null, null);
      res.elementBinders = binders;
      return res;
    }
    createElementInjector() {
      var host = new SpyElementInjector();
      return SpyObject.stub(new SpyElementInjector(), {
        "isExportingComponent": false,
        "isExportingElement": false,
        "getEventEmitterAccessors": [],
        "getHostActionAccessors": [],
        "getComponent": null,
        "getDynamicallyLoadedComponent": null,
        "getHost": host
      }, {});
    }
    createView([pv = null]) {
      if (isBlank(pv)) {
        pv = createProtoView();
      }
      var view = new AppView(null, pv, MapWrapper.create());
      var elementInjectors =
          ListWrapper.createFixedSize(pv.elementBinders.length);
      var preBuiltObjects =
          ListWrapper.createFixedSize(pv.elementBinders.length);
      for (var i = 0; i < pv.elementBinders.length; i++) {
        elementInjectors[i] = createElementInjector();
        preBuiltObjects[i] = new SpyPreBuiltObjects();
      }
      view.init(new SpyChangeDetector(), elementInjectors, elementInjectors,
          preBuiltObjects,
          ListWrapper.createFixedSize(pv.elementBinders.length));
      return view;
    }
    beforeEach(() {
      metadataReader = new DirectiveMetadataReader();
      utils = new AppViewManagerUtils(metadataReader);
    });
    describe("hydrateDynamicComponentInElementInjector", () {
      it("should not allow to overwrite an existing component", () {
        var hostView = createView(
            createProtoView([createComponentElBinder(createProtoView())]));
        var componentBinding = bind(SomeComponent).toClass(SomeComponent);
        SpyObject.stub(hostView.elementInjectors[0], {
          "getDynamicallyLoadedComponent": new SomeComponent()
        });
        expect(() => utils.hydrateDynamicComponentInElementInjector(
                hostView, 0, componentBinding, null)).toThrowError(
            "There already is a dynamic component loaded at element 0");
      });
    });
    describe("hydrateComponentView", () {
      it("should hydrate the change detector after hydrating element injectors",
          () {
        var log = new Log();
        var componentView =
            createView(createProtoView([createEmptyElBinder()]));
        var hostView = createView(
            createProtoView([createComponentElBinder(createProtoView())]));
        hostView.componentChildViews = [componentView];
        // (() => () nonsense is required until our transpiler supports type casting
        var spyEi = (() => componentView.elementInjectors[0])();
        spyEi
            .spy("instantiateDirectives")
            .andCallFake(log.fn("instantiateDirectives"));
        var spyCd = (() => componentView.changeDetector)();
        spyCd.spy("hydrate").andCallFake(log.fn("hydrateCD"));
        utils.hydrateComponentView(hostView, 0);
        expect(log.result()).toEqual("instantiateDirectives; hydrateCD");
      });
    });
    describe("shared hydrate functionality", () {
      it("should set up event listeners", () {
        var dir = new Object();
        var hostPv = createProtoView(
            [createComponentElBinder(null), createEmptyElBinder()]);
        var hostView = createView(hostPv);
        var spyEventAccessor1 = SpyObject.stub({"subscribe": null});
        SpyObject.stub(hostView.elementInjectors[0], {
          "getHostActionAccessors": [],
          "getEventEmitterAccessors": [[spyEventAccessor1]],
          "getDirectiveAtIndex": dir
        });
        var spyEventAccessor2 = SpyObject.stub({"subscribe": null});
        SpyObject.stub(hostView.elementInjectors[1], {
          "getHostActionAccessors": [],
          "getEventEmitterAccessors": [[spyEventAccessor2]],
          "getDirectiveAtIndex": dir
        });
        var shadowView = createView();
        utils.attachComponentView(hostView, 0, shadowView);
        utils.attachAndHydrateInPlaceHostView(
            null, null, hostView, createInjector());
        expect(spyEventAccessor1.spy("subscribe")).toHaveBeenCalledWith(
            hostView, 0, dir);
        expect(spyEventAccessor2.spy("subscribe")).toHaveBeenCalledWith(
            hostView, 1, dir);
      });
      it("should set up host action listeners", () {
        var dir = new Object();
        var hostPv = createProtoView(
            [createComponentElBinder(null), createEmptyElBinder()]);
        var hostView = createView(hostPv);
        var spyActionAccessor1 = SpyObject.stub({"subscribe": null});
        SpyObject.stub(hostView.elementInjectors[0], {
          "getHostActionAccessors": [[spyActionAccessor1]],
          "getEventEmitterAccessors": [],
          "getDirectiveAtIndex": dir
        });
        var spyActionAccessor2 = SpyObject.stub({"subscribe": null});
        SpyObject.stub(hostView.elementInjectors[1], {
          "getHostActionAccessors": [[spyActionAccessor2]],
          "getEventEmitterAccessors": [],
          "getDirectiveAtIndex": dir
        });
        var shadowView = createView();
        utils.attachComponentView(hostView, 0, shadowView);
        utils.attachAndHydrateInPlaceHostView(
            null, null, hostView, createInjector());
        expect(spyActionAccessor1.spy("subscribe")).toHaveBeenCalledWith(
            hostView, 0, dir);
        expect(spyActionAccessor2.spy("subscribe")).toHaveBeenCalledWith(
            hostView, 1, dir);
      });
    });
    describe("attachViewInContainer", () {
      var parentView, contextView, childView;
      createViews() {
        var parentPv = createProtoView([createEmptyElBinder()]);
        parentView = createView(parentPv);
        var contextPv = createProtoView([createEmptyElBinder()]);
        contextView = createView(contextPv);
        var childPv = createProtoView([createEmptyElBinder()]);
        childView = createView(childPv);
      }
      it("should link the views rootElementInjectors after the elementInjector at the given context",
          () {
        createViews();
        utils.attachViewInContainer(
            parentView, 0, contextView, 0, 0, childView);
        expect(childView.rootElementInjectors[0].spy("linkAfter"))
            .toHaveBeenCalledWith(contextView.elementInjectors[0], null);
      });
    });
    describe("hydrateViewInContainer", () {
      var parentView, contextView, childView;
      createViews() {
        var parentPv = createProtoView([createEmptyElBinder()]);
        parentView = createView(parentPv);
        var contextPv = createProtoView([createEmptyElBinder()]);
        contextView = createView(contextPv);
        var childPv = createProtoView([createEmptyElBinder()]);
        childView = createView(childPv);
        utils.attachViewInContainer(
            parentView, 0, contextView, 0, 0, childView);
      }
      it("should instantiate the elementInjectors with the host of the context's elementInjector",
          () {
        createViews();
        utils.hydrateViewInContainer(parentView, 0, contextView, 0, 0, null);
        expect(childView.rootElementInjectors[0].spy("instantiateDirectives"))
            .toHaveBeenCalledWith(null,
                contextView.elementInjectors[0].getHost(),
                childView.preBuiltObjects[0]);
      });
    });
  });
}
@Component(selector: "someComponent")
class SomeComponent {}
@proxy
class SpyElementInjector extends SpyObject implements ElementInjector {
  SpyElementInjector() : super(ElementInjector) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@proxy
class SpyChangeDetector extends SpyObject implements ChangeDetector {
  SpyChangeDetector() : super(ChangeDetector) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@proxy
class SpyPreBuiltObjects extends SpyObject implements PreBuiltObjects {
  SpyPreBuiltObjects() : super(PreBuiltObjects) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
