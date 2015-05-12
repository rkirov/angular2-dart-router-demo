library angular2.test.core.compiler.dynamic_component_loader_spec;

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
        xit;
import "package:angular2/src/test_lib/test_bed.dart" show TestBed;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/compiler/dynamic_component_loader.dart"
    show DynamicComponentLoader;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;
import "package:angular2/src/directives/if.dart" show If;
import "package:angular2/src/render/dom/dom_renderer.dart" show DomRenderer;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/core/compiler/view_manager.dart"
    show AppViewManager;

main() {
  describe("DynamicComponentLoader", () {
    describe("loading into existing location", () {
      it("should work", inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<dynamic-comp #dynamic></dynamic-comp>",
            directives: [DynamicComp]));
        tb.createView(MyComp).then((view) {
          var dynamicComponent = view.rawView.locals.get("dynamic");
          expect(dynamicComponent).toBeAnInstanceOf(DynamicComp);
          dynamicComponent.done.then((_) {
            view.detectChanges();
            expect(view.rootNodes).toHaveText("hello");
            async.done();
          });
        });
      }));
      it("should inject dependencies of the dynamically-loaded component",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<dynamic-comp #dynamic></dynamic-comp>",
            directives: [DynamicComp]));
        tb.createView(MyComp).then((view) {
          var dynamicComponent = view.rawView.locals.get("dynamic");
          dynamicComponent.done.then((ref) {
            expect(ref.instance.dynamicallyCreatedComponentService)
                .toBeAnInstanceOf(DynamicallyCreatedComponentService);
            async.done();
          });
        });
      }));
      it("should allow to destroy and create them via viewcontainer directives",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div><dynamic-comp #dynamic template=\"if: ctxBoolProp\"></dynamic-comp></div>",
            directives: [DynamicComp, If]));
        tb.createView(MyComp).then((view) {
          view.context.ctxBoolProp = true;
          view.detectChanges();
          var dynamicComponent =
              view.rawView.viewContainers[0].views[0].locals.get("dynamic");
          dynamicComponent.done.then((_) {
            view.detectChanges();
            expect(view.rootNodes).toHaveText("hello");
            view.context.ctxBoolProp = false;
            view.detectChanges();
            expect(view.rawView.viewContainers[0].views.length).toBe(0);
            expect(view.rootNodes).toHaveText("");
            view.context.ctxBoolProp = true;
            view.detectChanges();
            var dynamicComponent =
                view.rawView.viewContainers[0].views[0].locals.get("dynamic");
            return dynamicComponent.done;
          }).then((_) {
            view.detectChanges();
            expect(view.rootNodes).toHaveText("hello");
            async.done();
          });
        });
      }));
    });
    describe("loading next to an existing location", () {
      it("should work", inject([
        DynamicComponentLoader,
        TestBed,
        AsyncTestCompleter
      ], (loader, tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div><location #loc></location></div>",
            directives: [Location]));
        tb.createView(MyComp).then((view) {
          var location = view.rawView.locals.get("loc");
          loader
              .loadNextToExistingLocation(
                  DynamicallyLoaded, location.elementRef)
              .then((ref) {
            expect(view.rootNodes).toHaveText("Location;DynamicallyLoaded;");
            async.done();
          });
        });
      }));
      it("should return a disposable component ref", inject([
        DynamicComponentLoader,
        TestBed,
        AsyncTestCompleter
      ], (loader, tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div><location #loc></location></div>",
            directives: [Location]));
        tb.createView(MyComp).then((view) {
          var location = view.rawView.locals.get("loc");
          loader
              .loadNextToExistingLocation(
                  DynamicallyLoaded, location.elementRef)
              .then((ref) {
            loader
                .loadNextToExistingLocation(
                    DynamicallyLoaded2, location.elementRef)
                .then((ref2) {
              expect(view.rootNodes)
                  .toHaveText("Location;DynamicallyLoaded;DynamicallyLoaded2;");
              ref2.dispose();
              expect(view.rootNodes).toHaveText("Location;DynamicallyLoaded;");
              async.done();
            });
          });
        });
      }));
      it("should update host properties", inject([
        DynamicComponentLoader,
        TestBed,
        AsyncTestCompleter
      ], (loader, tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div><location #loc></location></div>",
            directives: [Location]));
        tb.createView(MyComp).then((view) {
          var location = view.rawView.locals.get("loc");
          loader
              .loadNextToExistingLocation(
                  DynamicallyLoadedWithHostProps, location.elementRef)
              .then((ref) {
            ref.instance.id = "new value";
            view.detectChanges();
            var newlyInsertedElement =
                DOM.childNodesAsList(view.rootNodes[0])[1];
            expect(newlyInsertedElement.id).toEqual("new value");
            async.done();
          });
        });
      }));
    });
    describe("loading into a new location", () {
      it("should allow to create, update and destroy components", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<imp-ng-cmp #impview></imp-ng-cmp>",
            directives: [ImperativeViewComponentUsingNgComponent]));
        tb.createView(MyComp).then((view) {
          var userViewComponent = view.rawView.locals.get("impview");
          userViewComponent.done.then((childComponentRef) {
            view.detectChanges();
            expect(view.rootNodes).toHaveText("hello");
            childComponentRef.instance.ctxProp = "new";
            view.detectChanges();
            expect(view.rootNodes).toHaveText("new");
            childComponentRef.dispose();
            expect(view.rootNodes).toHaveText("");
            async.done();
          });
        });
      }));
    });
  });
}
@Component(selector: "imp-ng-cmp")
@View(renderer: "imp-ng-cmp-renderer", template: "")
class ImperativeViewComponentUsingNgComponent {
  var done;
  ImperativeViewComponentUsingNgComponent(ElementRef self,
      DynamicComponentLoader dynamicComponentLoader, AppViewManager viewManager,
      DomRenderer renderer) {
    var div = el("<div id=\"impHost\"></div>");
    var shadowViewRef = viewManager.getComponentView(self);
    renderer.setComponentViewRootNodes(shadowViewRef.render, [div]);
    this.done = dynamicComponentLoader.loadIntoNewLocation(
        ChildComp, self, "#impHost", null);
  }
}
@Component(selector: "child-cmp")
@View(template: "{{ctxProp}}")
class ChildComp {
  String ctxProp;
  ChildComp() {
    this.ctxProp = "hello";
  }
}
class DynamicallyCreatedComponentService {}
@Component(selector: "dynamic-comp")
class DynamicComp {
  var done;
  DynamicComp(DynamicComponentLoader loader, ElementRef location) {
    this.done =
        loader.loadIntoExistingLocation(DynamicallyCreatedCmp, location);
  }
}
@Component(
    selector: "hello-cmp",
    injectables: const [DynamicallyCreatedComponentService])
@View(template: "{{greeting}}")
class DynamicallyCreatedCmp {
  String greeting;
  DynamicallyCreatedComponentService dynamicallyCreatedComponentService;
  DynamicallyCreatedCmp(DynamicallyCreatedComponentService a) {
    this.greeting = "hello";
    this.dynamicallyCreatedComponentService = a;
  }
}
@Component(selector: "dummy")
@View(template: "DynamicallyLoaded;")
class DynamicallyLoaded {}
@Component(selector: "dummy")
@View(template: "DynamicallyLoaded2;")
class DynamicallyLoaded2 {}
@Component(selector: "dummy", hostProperties: const {"id": "id"})
@View(template: "DynamicallyLoadedWithHostProps;")
class DynamicallyLoadedWithHostProps {
  String id;
  DynamicallyLoadedWithHostProps() {
    this.id = "default";
  }
}
@Component(selector: "location")
@View(template: "Location;")
class Location {
  ElementRef elementRef;
  Location(ElementRef elementRef) {
    this.elementRef = elementRef;
  }
}
@Component(selector: "my-comp")
@View(directives: const [])
class MyComp {
  bool ctxBoolProp;
  MyComp() {
    this.ctxBoolProp = false;
  }
}
