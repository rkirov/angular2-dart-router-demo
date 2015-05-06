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
import "package:angular2/src/facade/lang.dart"
    show IMPLEMENTS, isBlank, isPresent;
import "package:angular2/src/facade/collection.dart"
    show MapWrapper, ListWrapper, StringMapWrapper;
import "package:angular2/src/core/compiler/view.dart"
    show AppProtoView, AppView;
import "package:angular2/change_detection.dart" show ChangeDetector;
import "package:angular2/src/core/compiler/element_binder.dart"
    show ElementBinder;
import "package:angular2/src/core/compiler/element_injector.dart"
    show DirectiveBinding, ElementInjector, ElementRef;
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
      return SpyObject.stub(new SpyElementInjector(), {
        "isExportingComponent": false,
        "isExportingElement": false,
        "getEventEmitterAccessors": [],
        "getComponent": null,
        "getDynamicallyLoadedComponent": null
      }, {});
    }
    createView([pv = null]) {
      if (isBlank(pv)) {
        pv = createProtoView();
      }
      var view = new AppView(null, pv, MapWrapper.create());
      var elementInjectors =
          ListWrapper.createFixedSize(pv.elementBinders.length);
      for (var i = 0; i < pv.elementBinders.length; i++) {
        elementInjectors[i] = createElementInjector();
      }
      view.init(new SpyChangeDetector(), elementInjectors, [],
          ListWrapper.createFixedSize(pv.elementBinders.length),
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
        hostView.componentChildViews = [
          componentView
        ]; // (() => () nonsense is required until our transpiler supports type casting
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
          "getEventEmitterAccessors": [[spyEventAccessor1]],
          "getDirectiveAtIndex": dir
        });
        var spyEventAccessor2 = SpyObject.stub({"subscribe": null});
        SpyObject.stub(hostView.elementInjectors[1], {
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
    });
  });
}
@Component(selector: "someComponent")
class SomeComponent {}
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
@proxy
@IMPLEMENTS(ChangeDetector)
class SpyChangeDetector extends SpyObject implements ChangeDetector {
  SpyChangeDetector() : super(ChangeDetector) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
