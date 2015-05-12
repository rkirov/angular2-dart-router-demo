library angular2.test.core.compiler.integration_spec;

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
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/lang.dart"
    show Type, isPresent, BaseException, assertionsEnabled, isJsObject, global;
import "package:angular2/src/facade/async.dart"
    show PromiseWrapper, EventEmitter, ObservableWrapper;
import "package:angular2/di.dart" show Injector, bind;
import "package:angular2/change_detection.dart"
    show
        PipeRegistry,
        defaultPipeRegistry,
        ChangeDetection,
        DynamicChangeDetection,
        Pipe,
        ChangeDetectorRef,
        ON_PUSH;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive, Component;
import "package:angular2/src/core/compiler/dynamic_component_loader.dart"
    show DynamicComponentLoader;
import "package:angular2/src/core/compiler/query_list.dart" show QueryList;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/annotations_impl/visibility.dart"
    show Parent, Ancestor;
import "package:angular2/src/core/annotations_impl/di.dart"
    show Attribute, Query;
import "package:angular2/src/directives/if.dart" show If;
import "package:angular2/src/directives/for.dart" show For;
import "package:angular2/src/core/compiler/view_container_ref.dart"
    show ViewContainerRef;
import "package:angular2/src/core/compiler/view_ref.dart" show ProtoViewRef;
import "package:angular2/src/core/compiler/compiler.dart" show Compiler;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;
import "package:angular2/src/render/dom/dom_renderer.dart" show DomRenderer;
import "package:angular2/src/core/compiler/view_manager.dart"
    show AppViewManager;

main() {
  describe("integration tests", () {
    var ctx;
    beforeEach(() {
      ctx = new MyComp();
    });
    describe("react to record changes", () {
      it("should consume text node changes", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(template: "<div>{{ctxProp}}</div>"));
        tb.createView(MyComp, context: ctx).then((view) {
          ctx.ctxProp = "Hello World!";
          view.detectChanges();
          expect(DOM.getInnerHTML(view.rootNodes[0])).toEqual("Hello World!");
          async.done();
        });
      }));
      it("should consume element binding changes", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(
            MyComp, new View(template: "<div [id]=\"ctxProp\"></div>"));
        tb.createView(MyComp, context: ctx).then((view) {
          ctx.ctxProp = "Hello World!";
          view.detectChanges();
          expect(view.rootNodes[0].id).toEqual("Hello World!");
          async.done();
        });
      }));
      it("should consume binding to aria-* attributes", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp,
            new View(template: "<div [attr.aria-label]=\"ctxProp\"></div>"));
        tb.createView(MyComp, context: ctx).then((view) {
          ctx.ctxProp = "Initial aria label";
          view.detectChanges();
          expect(DOM.getAttribute(view.rootNodes[0], "aria-label"))
              .toEqual("Initial aria label");
          ctx.ctxProp = "Changed aria label";
          view.detectChanges();
          expect(DOM.getAttribute(view.rootNodes[0], "aria-label"))
              .toEqual("Changed aria label");
          async.done();
        });
      }));
      it("should consume binding to property names where attr name and property name do not match",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp,
            new View(template: "<div [tabindex]=\"ctxNumProp\"></div>"));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          expect(view.rootNodes[0].tabIndex).toEqual(0);
          ctx.ctxNumProp = 5;
          view.detectChanges();
          expect(view.rootNodes[0].tabIndex).toEqual(5);
          async.done();
        });
      }));
      it("should consume binding to camel-cased properties using dash-cased syntax in templates",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(
            MyComp, new View(template: "<input [read-only]=\"ctxBoolProp\">"));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          expect(view.rootNodes[0].readOnly).toBeFalsy();
          ctx.ctxBoolProp = true;
          view.detectChanges();
          expect(view.rootNodes[0].readOnly).toBeTruthy();
          async.done();
        });
      }));
      it("should consume binding to inner-html", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp,
            new View(template: "<div inner-html=\"{{ctxProp}}\"></div>"));
        tb.createView(MyComp, context: ctx).then((view) {
          ctx.ctxProp = "Some <span>HTML</span>";
          view.detectChanges();
          expect(DOM.getInnerHTML(view.rootNodes[0]))
              .toEqual("Some <span>HTML</span>");
          ctx.ctxProp = "Some other <div>HTML</div>";
          view.detectChanges();
          expect(DOM.getInnerHTML(view.rootNodes[0]))
              .toEqual("Some other <div>HTML</div>");
          async.done();
        });
      }));
      it("should ignore bindings to unknown properties", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(
            MyComp, new View(template: "<div unknown=\"{{ctxProp}}\"></div>"));
        tb.createView(MyComp, context: ctx).then((view) {
          ctx.ctxProp = "Some value";
          view.detectChanges();
          expect(DOM.hasProperty(view.rootNodes[0], "unknown")).toBeFalsy();
          async.done();
        });
      }));
      it("should consume directive watch expression change.", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        var tpl = "<div>" +
            "<div my-dir [elprop]=\"ctxProp\"></div>" +
            "<div my-dir elprop=\"Hi there!\"></div>" +
            "<div my-dir elprop=\"Hi {{'there!'}}\"></div>" +
            "<div my-dir elprop=\"One more {{ctxProp}}\"></div>" +
            "</div>";
        tb.overrideView(MyComp, new View(template: tpl, directives: [MyDir]));
        tb.createView(MyComp, context: ctx).then((view) {
          ctx.ctxProp = "Hello World!";
          view.detectChanges();
          expect(view.rawView.elementInjectors[0].get(MyDir).dirProp)
              .toEqual("Hello World!");
          expect(view.rawView.elementInjectors[1].get(MyDir).dirProp)
              .toEqual("Hi there!");
          expect(view.rawView.elementInjectors[2].get(MyDir).dirProp)
              .toEqual("Hi there!");
          expect(view.rawView.elementInjectors[3].get(MyDir).dirProp)
              .toEqual("One more Hello World!");
          async.done();
        });
      }));
      describe("pipes", () {
        beforeEachBindings(() {
          return [
            bind(ChangeDetection).toFactory(() => new DynamicChangeDetection(
                new PipeRegistry({"double": [new DoublePipeFactory()]})), [])
          ];
        });
        it("should support pipes in bindings and bind config", inject([
          TestBed,
          AsyncTestCompleter
        ], (tb, async) {
          tb.overrideView(MyComp, new View(
              template: "<component-with-pipes #comp [prop]=\"ctxProp | double\"></component-with-pipes>",
              directives: [ComponentWithPipes]));
          tb.createView(MyComp, context: ctx).then((view) {
            ctx.ctxProp = "a";
            view.detectChanges();
            var comp = view.rawView.locals.get("comp");
            // it is doubled twice: once in the binding, second time in the bind config
            expect(comp.prop).toEqual("aaaa");
            async.done();
          });
        }));
      });
      it("should support nested components.", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<child-cmp></child-cmp>", directives: [ChildComp]));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          expect(view.rootNodes).toHaveText("hello");
          async.done();
        });
      }));
      // GH issue 328 - https://github.com/angular/angular/issues/328
      it("should support different directive types on a single node", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<child-cmp my-dir [elprop]=\"ctxProp\"></child-cmp>",
            directives: [MyDir, ChildComp]));
        tb.createView(MyComp, context: ctx).then((view) {
          ctx.ctxProp = "Hello World!";
          view.detectChanges();
          var elInj = view.rawView.elementInjectors[0];
          expect(elInj.get(MyDir).dirProp).toEqual("Hello World!");
          expect(elInj.get(ChildComp).dirProp).toEqual(null);
          async.done();
        });
      }));
      it("should support directives where a binding attribute is not given",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(
            MyComp, new View(template: "<p my-dir></p>", directives: [MyDir]));
        tb.createView(MyComp, context: ctx).then((view) {
          async.done();
        });
      }));
      it("should support directives where a selector matches property binding",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<p [id]=\"ctxProp\"></p>", directives: [IdDir]));
        tb.createView(MyComp, context: ctx).then((view) {
          var idDir = view.rawView.elementInjectors[0].get(IdDir);
          ctx.ctxProp = "some_id";
          view.detectChanges();
          expect(idDir.id).toEqual("some_id");
          ctx.ctxProp = "other_id";
          view.detectChanges();
          expect(idDir.id).toEqual("other_id");
          async.done();
        });
      }));
      it("should allow specifying directives as bindings", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<child-cmp></child-cmp>",
            directives: [bind(ChildComp).toClass(ChildComp)]));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          expect(view.rootNodes).toHaveText("hello");
          async.done();
        });
      }));
      it("should read directives metadata from their binding token", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div public-api><div needs-public-api></div></div>",
            directives: [
          bind(PublicApi).toClass(PrivateImpl),
          NeedsPublicApi
        ]));
        tb.createView(MyComp, context: ctx).then((view) {
          async.done();
        });
      }));
      it("should support template directives via `<template>` elements.",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div><template some-viewport var-greeting=\"some-tmpl\"><copy-me>{{greeting}}</copy-me></template></div>",
            directives: [SomeViewport]));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          var childNodesOfWrapper = view.rootNodes[0].childNodes;
          // 1 template + 2 copies.
          expect(childNodesOfWrapper.length).toBe(3);
          expect(childNodesOfWrapper[1].childNodes[0].nodeValue)
              .toEqual("hello");
          expect(childNodesOfWrapper[2].childNodes[0].nodeValue)
              .toEqual("again");
          async.done();
        });
      }));
      it("should support template directives via `template` attribute.", inject(
          [TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div><copy-me template=\"some-viewport: var greeting=some-tmpl\">{{greeting}}</copy-me></div>",
            directives: [SomeViewport]));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          var childNodesOfWrapper = view.rootNodes[0].childNodes;
          // 1 template + 2 copies.
          expect(childNodesOfWrapper.length).toBe(3);
          expect(childNodesOfWrapper[1].childNodes[0].nodeValue)
              .toEqual("hello");
          expect(childNodesOfWrapper[2].childNodes[0].nodeValue)
              .toEqual("again");
          async.done();
        });
      }));
      it("should allow to transplant embedded ProtoViews into other ViewContainers",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<some-directive><toolbar><template toolbarpart var-toolbar-prop=\"toolbarProp\">{{ctxProp}},{{toolbarProp}},<cmp-with-parent></cmp-with-parent></template></toolbar></some-directive>",
            directives: [
          SomeDirective,
          CompWithParent,
          ToolbarComponent,
          ToolbarPart
        ]));
        ctx.ctxProp = "From myComp";
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          expect(view.rootNodes).toHaveText(
              "TOOLBAR(From myComp,From toolbar,Component with an injected parent)");
          async.done();
        });
      }));
      it("should assign the component instance to a var-", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<p><child-cmp var-alice></child-cmp></p>",
            directives: [ChildComp]));
        tb.createView(MyComp, context: ctx).then((view) {
          expect(view.rawView.locals).not.toBe(null);
          expect(view.rawView.locals.get("alice")).toBeAnInstanceOf(ChildComp);
          async.done();
        });
      }));
      it("should make the assigned component accessible in property bindings",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<p><child-cmp var-alice></child-cmp>{{alice.ctxProp}}</p>",
            directives: [ChildComp]));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          expect(view.rootNodes).toHaveText("hellohello");
          async.done();
        });
      }));
      it("should assign two component instances each with a var-", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<p><child-cmp var-alice></child-cmp><child-cmp var-bob></p>",
            directives: [ChildComp]));
        tb.createView(MyComp, context: ctx).then((view) {
          expect(view.rawView.locals).not.toBe(null);
          expect(view.rawView.locals.get("alice")).toBeAnInstanceOf(ChildComp);
          expect(view.rawView.locals.get("bob")).toBeAnInstanceOf(ChildComp);
          expect(view.rawView.locals.get("alice")).not
              .toBe(view.rawView.locals.get("bob"));
          async.done();
        });
      }));
      it("should assign the component instance to a var- with shorthand syntax",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<child-cmp #alice></child-cmp>",
            directives: [ChildComp]));
        tb.createView(MyComp, context: ctx).then((view) {
          expect(view.rawView.locals).not.toBe(null);
          expect(view.rawView.locals.get("alice")).toBeAnInstanceOf(ChildComp);
          async.done();
        });
      }));
      it("should assign the element instance to a user-defined variable",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp,
            new View(template: "<p><div var-alice><i>Hello</i></div></p>"));
        tb.createView(MyComp, context: ctx).then((view) {
          expect(view.rawView.locals).not.toBe(null);
          var value = view.rawView.locals.get("alice");
          expect(value).not.toBe(null);
          expect(value.tagName.toLowerCase()).toEqual("div");
          async.done();
        });
      }));
      it("should assign the element instance to a user-defined variable with camelCase using dash-case",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<p><div var-super-alice><i>Hello</i></div></p>"));
        tb.createView(MyComp, context: ctx).then((view) {
          expect(view.rawView.locals).not.toBe(null);
          var value = view.rawView.locals.get("superAlice");
          expect(value).not.toBe(null);
          expect(value.tagName.toLowerCase()).toEqual("div");
          async.done();
        });
      }));
      describe("ON_PUSH components", () {
        it("should use ChangeDetectorRef to manually request a check", inject([
          TestBed,
          AsyncTestCompleter
        ], (tb, async) {
          tb.overrideView(MyComp, new View(
              template: "<push-cmp-with-ref #cmp></push-cmp-with-ref>",
              directives: [[[PushCmpWithRef]]]));
          tb.createView(MyComp, context: ctx).then((view) {
            var cmp = view.rawView.locals.get("cmp");
            view.detectChanges();
            expect(cmp.numberOfChecks).toEqual(1);
            view.detectChanges();
            expect(cmp.numberOfChecks).toEqual(1);
            cmp.propagate();
            view.detectChanges();
            expect(cmp.numberOfChecks).toEqual(2);
            async.done();
          });
        }));
        it("should be checked when its bindings got updated", inject([
          TestBed,
          AsyncTestCompleter
        ], (tb, async) {
          tb.overrideView(MyComp, new View(
              template: "<push-cmp [prop]=\"ctxProp\" #cmp></push-cmp>",
              directives: [[[PushCmp]]]));
          tb.createView(MyComp, context: ctx).then((view) {
            var cmp = view.rawView.locals.get("cmp");
            ctx.ctxProp = "one";
            view.detectChanges();
            expect(cmp.numberOfChecks).toEqual(1);
            ctx.ctxProp = "two";
            view.detectChanges();
            expect(cmp.numberOfChecks).toEqual(2);
            async.done();
          });
        }));
        it("should not affect updating properties on the component", inject([
          TestBed,
          AsyncTestCompleter
        ], (tb, async) {
          tb.overrideView(MyComp, new View(
              template: "<push-cmp-with-ref [prop]=\"ctxProp\" #cmp></push-cmp-with-ref>",
              directives: [[[PushCmpWithRef]]]));
          tb.createView(MyComp, context: ctx).then((view) {
            var cmp = view.rawView.locals.get("cmp");
            ctx.ctxProp = "one";
            view.detectChanges();
            expect(cmp.prop).toEqual("one");
            ctx.ctxProp = "two";
            view.detectChanges();
            expect(cmp.prop).toEqual("two");
            async.done();
          });
        }));
      });
      it("should create a component that injects a @Parent", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<some-directive><cmp-with-parent #child></cmp-with-parent></some-directive>",
            directives: [SomeDirective, CompWithParent]));
        tb.createView(MyComp, context: ctx).then((view) {
          var childComponent = view.rawView.locals.get("child");
          expect(childComponent.myParent).toBeAnInstanceOf(SomeDirective);
          async.done();
        });
      }));
      it("should create a component that injects an @Ancestor", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(template: '''
            <some-directive>
              <p>
                <cmp-with-ancestor #child></cmp-with-ancestor>
              </p>
            </some-directive>''',
            directives: [SomeDirective, CompWithAncestor]));
        tb.createView(MyComp, context: ctx).then((view) {
          var childComponent = view.rawView.locals.get("child");
          expect(childComponent.myAncestor).toBeAnInstanceOf(SomeDirective);
          async.done();
        });
      }));
      it("should create a component that injects an @Ancestor through viewcontainer directive",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(template: '''
            <some-directive>
              <p *if="true">
                <cmp-with-ancestor #child></cmp-with-ancestor>
              </p>
            </some-directive>''',
            directives: [SomeDirective, CompWithAncestor, If]));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          var subview = view.rawView.viewContainers[1].views[0];
          var childComponent = subview.locals.get("child");
          expect(childComponent.myAncestor).toBeAnInstanceOf(SomeDirective);
          async.done();
        });
      }));
      it("should support events via EventEmitter", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div emitter listener></div>",
            directives: [DirectiveEmitingEvent, DirectiveListeningEvent]));
        tb.createView(MyComp, context: ctx).then((view) {
          var injector = view.rawView.elementInjectors[0];
          var emitter = injector.get(DirectiveEmitingEvent);
          var listener = injector.get(DirectiveListeningEvent);
          expect(listener.msg).toEqual("");
          ObservableWrapper.subscribe(emitter.event, (_) {
            expect(listener.msg).toEqual("fired !");
            async.done();
          });
          emitter.fireEvent("fired !");
        });
      }));
      if (DOM.supportsDOMEvents()) {
        it("should support invoking methods on the host element via hostActions",
            inject([TestBed, AsyncTestCompleter], (tb, async) {
          tb.overrideView(MyComp, new View(
              template: "<div update-host-actions></div>",
              directives: [DirectiveUpdatingHostActions]));
          tb.createView(MyComp, context: ctx).then((view) {
            var injector = view.rawView.elementInjectors[0];
            var domElement = view.rootNodes[0];
            var updateHost = injector.get(DirectiveUpdatingHostActions);
            ObservableWrapper.subscribe(updateHost.setAttr, (_) {
              expect(DOM.getOuterHTML(domElement)).toEqual(
                  "<div update-host-actions=\"\" class=\"ng-binding\" key=\"value\"></div>");
              async.done();
            });
            updateHost.triggerSetAttr("value");
          });
        }));
      }
      it("should support render events", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div listener></div>",
            directives: [DirectiveListeningDomEvent]));
        tb.createView(MyComp, context: ctx).then((view) {
          var injector = view.rawView.elementInjectors[0];
          var listener = injector.get(DirectiveListeningDomEvent);
          dispatchEvent(view.rootNodes[0], "domEvent");
          expect(listener.eventType).toEqual("domEvent");
          async.done();
        });
      }));
      it("should support render global events", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div listener></div>",
            directives: [DirectiveListeningDomEvent]));
        tb.createView(MyComp, context: ctx).then((view) {
          var injector = view.rawView.elementInjectors[0];
          var listener = injector.get(DirectiveListeningDomEvent);
          dispatchEvent(DOM.getGlobalEventTarget("window"), "domEvent");
          expect(listener.eventType).toEqual("window_domEvent");
          listener = injector.get(DirectiveListeningDomEvent);
          dispatchEvent(DOM.getGlobalEventTarget("document"), "domEvent");
          expect(listener.eventType).toEqual("document_domEvent");
          view.destroy();
          listener = injector.get(DirectiveListeningDomEvent);
          dispatchEvent(DOM.getGlobalEventTarget("body"), "domEvent");
          expect(listener.eventType).toEqual("");
          async.done();
        });
      }));
      it("should support updating host element via hostAttributes", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div update-host-attributes></div>",
            directives: [DirectiveUpdatingHostAttributes]));
        tb.createView(MyComp, context: ctx).then((view) {
          view.detectChanges();
          expect(DOM.getAttribute(view.rootNodes[0], "role")).toEqual("button");
          async.done();
        });
      }));
      it("should support updating host element via hostProperties", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div update-host-properties></div>",
            directives: [DirectiveUpdatingHostProperties]));
        tb.createView(MyComp, context: ctx).then((view) {
          var injector = view.rawView.elementInjectors[0];
          var updateHost = injector.get(DirectiveUpdatingHostProperties);
          updateHost.id = "newId";
          view.detectChanges();
          expect(view.rootNodes[0].id).toEqual("newId");
          async.done();
        });
      }));
      if (DOM.supportsDOMEvents()) {
        it("should support preventing default on render events", inject([
          TestBed,
          AsyncTestCompleter
        ], (tb, async) {
          tb.overrideView(MyComp, new View(
              template: "<input type=\"checkbox\" listenerprevent></input><input type=\"checkbox\" listenernoprevent></input>",
              directives: [
            DirectiveListeningDomEventPrevent,
            DirectiveListeningDomEventNoPrevent
          ]));
          tb.createView(MyComp, context: ctx).then((view) {
            expect(DOM.getChecked(view.rootNodes[0])).toBeFalsy();
            expect(DOM.getChecked(view.rootNodes[1])).toBeFalsy();
            DOM.dispatchEvent(view.rootNodes[0], DOM.createMouseEvent("click"));
            DOM.dispatchEvent(view.rootNodes[1], DOM.createMouseEvent("click"));
            expect(DOM.getChecked(view.rootNodes[0])).toBeFalsy();
            expect(DOM.getChecked(view.rootNodes[1])).toBeTruthy();
            async.done();
          });
        }));
      }
      it("should support render global events from multiple directives", inject(
          [TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<div *if=\"ctxBoolProp\" listener listenerother></div>",
            directives: [
          If,
          DirectiveListeningDomEvent,
          DirectiveListeningDomEventOther
        ]));
        tb.createView(MyComp, context: ctx).then((view) {
          globalCounter = 0;
          ctx.ctxBoolProp = true;
          view.detectChanges();
          var subview = view.rawView.viewContainers[0].views[0];
          var injector = subview.elementInjectors[0];
          var listener = injector.get(DirectiveListeningDomEvent);
          var listenerother = injector.get(DirectiveListeningDomEventOther);
          dispatchEvent(DOM.getGlobalEventTarget("window"), "domEvent");
          expect(listener.eventType).toEqual("window_domEvent");
          expect(listenerother.eventType).toEqual("other_domEvent");
          expect(globalCounter).toEqual(1);
          ctx.ctxBoolProp = false;
          view.detectChanges();
          dispatchEvent(DOM.getGlobalEventTarget("window"), "domEvent");
          expect(globalCounter).toEqual(1);
          ctx.ctxBoolProp = true;
          view.detectChanges();
          dispatchEvent(DOM.getGlobalEventTarget("window"), "domEvent");
          expect(globalCounter).toEqual(2);
          async.done();
        });
      }));
      describe("dynamic ViewContainers", () {
        it("should allow to create a ViewContainerRef at any bound location",
            inject([
          TestBed,
          AsyncTestCompleter,
          Compiler
        ], (tb, async, compiler) {
          tb.overrideView(MyComp, new View(
              template: "<div><dynamic-vp #dynamic></dynamic-vp></div>",
              directives: [DynamicViewport]));
          tb.createView(MyComp).then((view) {
            var dynamicVp =
                view.rawView.elementInjectors[0].get(DynamicViewport);
            dynamicVp.done.then((_) {
              view.detectChanges();
              expect(view.rootNodes).toHaveText("dynamic greet");
              async.done();
            });
          });
        }));
      });
      it("should support static attributes", inject([
        TestBed,
        AsyncTestCompleter
      ], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<input static type=\"text\" title>",
            directives: [NeedsAttribute]));
        tb.createView(MyComp, context: ctx).then((view) {
          var injector = view.rawView.elementInjectors[0];
          var needsAttribute = injector.get(NeedsAttribute);
          expect(needsAttribute.typeAttribute).toEqual("text");
          expect(needsAttribute.titleAttribute).toEqual("");
          expect(needsAttribute.fooAttribute).toEqual(null);
          async.done();
        });
      }));
    });
    describe("error handling", () {
      it("should specify a location of an error that happened during change detection (text)",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(template: "{{a.b}}"));
        tb.createView(MyComp, context: ctx).then((view) {
          expect(() => view.detectChanges())
              .toThrowError(new RegExp("{{a.b}} in MyComp"));
          async.done();
        });
      }));
      it("should specify a location of an error that happened during change detection (element property)",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(
            MyComp, new View(template: "<div [prop]=\"a.b\"></div>"));
        tb.createView(MyComp, context: ctx).then((view) {
          expect(() => view.detectChanges())
              .toThrowError(new RegExp("a.b in MyComp"));
          async.done();
        });
      }));
      it("should specify a location of an error that happened during change detection (directive property)",
          inject([TestBed, AsyncTestCompleter], (tb, async) {
        tb.overrideView(MyComp, new View(
            template: "<child-cmp [prop]=\"a.b\"></child-cmp>",
            directives: [ChildComp]));
        tb.createView(MyComp, context: ctx).then((view) {
          expect(() => view.detectChanges())
              .toThrowError(new RegExp("a.b in MyComp"));
          async.done();
        });
      }));
    });
    it("should support imperative views", inject([
      TestBed,
      AsyncTestCompleter
    ], (tb, async) {
      tb.overrideView(MyComp, new View(
          template: "<simple-imp-cmp></simple-imp-cmp>",
          directives: [SimpleImperativeViewComponent]));
      tb.createView(MyComp).then((view) {
        expect(view.rootNodes).toHaveText("hello imp view");
        async.done();
      });
    }));
    // Disabled until a solution is found, refs:

    // - https://github.com/angular/angular/issues/776

    // - https://github.com/angular/angular/commit/81f3f32
    xdescribe("Missing directive checks", () {
      if (assertionsEnabled()) {
        expectCompileError(tb, inlineTpl, errMessage, done) {
          tb.overrideView(MyComp, new View(template: inlineTpl));
          PromiseWrapper.then(tb.createView(MyComp), (value) {
            throw new BaseException(
                "Test failure: should not have come here as an exception was expected");
          }, (err) {
            expect(err.message).toEqual(errMessage);
            done();
          });
        }
        it("should raise an error if no directive is registered for a template with template bindings",
            inject([TestBed, AsyncTestCompleter], (tb, async) {
          expectCompileError(tb, "<div><div template=\"if: foo\"></div></div>",
              "Missing directive to handle 'if' in <div template=\"if: foo\">",
              () => async.done());
        }));
        it("should raise an error for missing template directive (1)", inject([
          TestBed,
          AsyncTestCompleter
        ], (tb, async) {
          expectCompileError(tb, "<div><template foo></template></div>",
              "Missing directive to handle: <template foo>",
              () => async.done());
        }));
        it("should raise an error for missing template directive (2)", inject([
          TestBed,
          AsyncTestCompleter
        ], (tb, async) {
          expectCompileError(tb,
              "<div><template *if=\"condition\"></template></div>",
              "Missing directive to handle: <template *if=\"condition\">",
              () => async.done());
        }));
        it("should raise an error for missing template directive (3)", inject([
          TestBed,
          AsyncTestCompleter
        ], (tb, async) {
          expectCompileError(tb, "<div *if=\"condition\"></div>",
              "Missing directive to handle 'if' in MyComp: <div *if=\"condition\">",
              () => async.done());
        }));
      }
    });
    describe("dependency injection", () {
      it("should publish parent component to shadow DOM via publishAs", inject([
        TestBed,
        AsyncTestCompleter,
        Compiler
      ], (tb, async, compiler) {
        tb.overrideView(MyComp, new View(
            template: '''<parent></parent>''', directives: [ParentComponent]));
        tb.createView(MyComp).then((view) {
          view.detectChanges();
          expect(view.rootNodes).toHaveText("Parent,Parent");
          async.done();
        });
      }));
      it("should override parent bindings via publishAs", inject([
        TestBed,
        AsyncTestCompleter,
        Compiler
      ], (tb, async, compiler) {
        tb.overrideView(MyComp, new View(
            template: '''<recursive-parent></recursive-parent>''',
            directives: [RecursiveParentComponent]));
        tb.createView(MyComp).then((view) {
          view.detectChanges();
          expect(view.rootNodes)
              .toHaveText("ParentInterface,RecursiveParent,RecursiveParent");
          async.done();
        });
      }));
      // [DynamicComponentLoader] already supports providing a custom

      // injector as an argument to `loadIntoExistingLocation`, which should

      // be used instead of `publishAs`.

      //

      // Conceptually dynamically loaded components are loaded _instead_ of

      // the dynamic component itself. The dynamic component does not own the

      // shadow DOM. It's the loaded component that creates that shadow DOM.
      it("should not publish into dynamically instantiated components via publishAs",
          inject([
        TestBed,
        AsyncTestCompleter,
        Compiler
      ], (tb, async, compiler) {
        tb.overrideView(MyComp, new View(
            template: '''<dynamic-parent #cmp></dynamic-parent>''',
            directives: [DynamicParentComponent]));
        tb.createView(MyComp).then((view) {
          view.detectChanges();
          var comp = view.rawView.locals.get("cmp");
          PromiseWrapper.then(comp.done, (value) {
            throw new BaseException(
                '''Expected to throw error, but got value ${ value}''');
          }, (err) {
            expect(err.message).toEqual(
                "No provider for ParentInterface! (ChildComponent -> ParentInterface)");
            async.done();
          });
        });
      }));
    });
  });
}
@Component(selector: "simple-imp-cmp")
@View(renderer: "simple-imp-cmp-renderer", template: "")
class SimpleImperativeViewComponent {
  var done;
  SimpleImperativeViewComponent(
      ElementRef self, AppViewManager viewManager, DomRenderer renderer) {
    var shadowViewRef = viewManager.getComponentView(self);
    renderer.setComponentViewRootNodes(
        shadowViewRef.render, [el("hello imp view")]);
  }
}
@Directive(selector: "dynamic-vp")
class DynamicViewport {
  var done;
  DynamicViewport(ViewContainerRef vc, Injector inj, Compiler compiler) {
    var myService = new MyService();
    myService.greeting = "dynamic greet";
    this.done = compiler.compileInHost(ChildCompUsingService).then((hostPv) {
      vc.create(hostPv, 0, null, inj.createChildFromResolved(
          Injector.resolve([bind(MyService).toValue(myService)])));
    });
  }
}
@Directive(selector: "[my-dir]", properties: const {"dirProp": "elprop"})
class MyDir {
  String dirProp;
  MyDir() {
    this.dirProp = "";
  }
}
@Component(
    selector: "push-cmp",
    properties: const {"prop": "prop"},
    changeDetection: ON_PUSH)
@View(template: "{{field}}")
class PushCmp {
  num numberOfChecks;
  var prop;
  PushCmp() {
    this.numberOfChecks = 0;
  }
  get field {
    this.numberOfChecks++;
    return "fixed";
  }
}
@Component(
    selector: "push-cmp-with-ref",
    properties: const {"prop": "prop"},
    changeDetection: ON_PUSH)
@View(template: "{{field}}")
class PushCmpWithRef {
  num numberOfChecks;
  ChangeDetectorRef ref;
  var prop;
  PushCmpWithRef(ChangeDetectorRef ref) {
    this.numberOfChecks = 0;
    this.ref = ref;
  }
  get field {
    this.numberOfChecks++;
    return "fixed";
  }
  propagate() {
    this.ref.requestCheck();
  }
}
@Component(selector: "my-comp")
@View(directives: const [])
class MyComp {
  String ctxProp;
  var ctxNumProp;
  var ctxBoolProp;
  MyComp() {
    this.ctxProp = "initial value";
    this.ctxNumProp = 0;
    this.ctxBoolProp = false;
  }
}
@Component(
    selector: "component-with-pipes",
    properties: const {"prop": "prop | double"})
@View(template: "")
class ComponentWithPipes {
  String prop;
}
@Component(selector: "child-cmp", injectables: const [MyService])
@View(directives: const [MyDir], template: "{{ctxProp}}")
class ChildComp {
  String ctxProp;
  String dirProp;
  ChildComp(MyService service) {
    this.ctxProp = service.greeting;
    this.dirProp = null;
  }
}
@Component(selector: "child-cmp-svc")
@View(template: "{{ctxProp}}")
class ChildCompUsingService {
  String ctxProp;
  ChildCompUsingService(MyService service) {
    this.ctxProp = service.greeting;
  }
}
@Directive(selector: "some-directive")
class SomeDirective {}
@Component(selector: "cmp-with-parent")
@View(
    template: "<p>Component with an injected parent</p>",
    directives: const [SomeDirective])
class CompWithParent {
  SomeDirective myParent;
  CompWithParent(@Parent() SomeDirective someComp) {
    this.myParent = someComp;
  }
}
@Component(selector: "cmp-with-ancestor")
@View(
    template: "<p>Component with an injected ancestor</p>",
    directives: const [SomeDirective])
class CompWithAncestor {
  SomeDirective myAncestor;
  CompWithAncestor(@Ancestor() SomeDirective someComp) {
    this.myAncestor = someComp;
  }
}
@Component(selector: "[child-cmp2]", injectables: const [MyService])
class ChildComp2 {
  String ctxProp;
  String dirProp;
  ChildComp2(MyService service) {
    this.ctxProp = service.greeting;
    this.dirProp = null;
  }
}
@Directive(selector: "[some-viewport]")
class SomeViewport {
  SomeViewport(ViewContainerRef container, ProtoViewRef protoView) {
    container.create(protoView).setLocal("some-tmpl", "hello");
    container.create(protoView).setLocal("some-tmpl", "again");
  }
}
class MyService {
  String greeting;
  MyService() {
    this.greeting = "hello";
  }
}
class DoublePipe extends Pipe {
  supports(obj) {
    return true;
  }
  transform(value) {
    return '''${ value}${ value}''';
  }
}
class DoublePipeFactory {
  supports(obj) {
    return true;
  }
  create(cdRef) {
    return new DoublePipe();
  }
}
@Directive(selector: "[emitter]", events: const ["event"])
class DirectiveEmitingEvent {
  String msg;
  EventEmitter event;
  DirectiveEmitingEvent() {
    this.msg = "";
    this.event = new EventEmitter();
  }
  fireEvent(String msg) {
    ObservableWrapper.callNext(this.event, msg);
  }
}
@Directive(
    selector: "[update-host-attributes]",
    hostAttributes: const {"role": "button"})
class DirectiveUpdatingHostAttributes {}
@Directive(
    selector: "[update-host-properties]", hostProperties: const {"id": "id"})
class DirectiveUpdatingHostProperties {
  String id;
  DirectiveUpdatingHostProperties() {
    this.id = "one";
  }
}
@Directive(
    selector: "[update-host-actions]",
    hostActions: const {
  "setAttr": "setAttribute(\"key\", \$action[\"attrValue\"])"
})
class DirectiveUpdatingHostActions {
  EventEmitter setAttr;
  DirectiveUpdatingHostActions() {
    this.setAttr = new EventEmitter();
  }
  triggerSetAttr(attrValue) {
    ObservableWrapper.callNext(this.setAttr, {"attrValue": attrValue});
  }
}
@Directive(
    selector: "[listener]", hostListeners: const {"event": "onEvent(\$event)"})
class DirectiveListeningEvent {
  String msg;
  DirectiveListeningEvent() {
    this.msg = "";
  }
  onEvent(String msg) {
    this.msg = msg;
  }
}
@Directive(
    selector: "[listener]",
    hostListeners: const {
  "domEvent": "onEvent(\$event.type)",
  "window:domEvent": "onWindowEvent(\$event.type)",
  "document:domEvent": "onDocumentEvent(\$event.type)",
  "body:domEvent": "onBodyEvent(\$event.type)"
})
class DirectiveListeningDomEvent {
  String eventType;
  DirectiveListeningDomEvent() {
    this.eventType = "";
  }
  onEvent(String eventType) {
    this.eventType = eventType;
  }
  onWindowEvent(String eventType) {
    this.eventType = "window_" + eventType;
  }
  onDocumentEvent(String eventType) {
    this.eventType = "document_" + eventType;
  }
  onBodyEvent(String eventType) {
    this.eventType = "body_" + eventType;
  }
}
var globalCounter = 0;
@Directive(
    selector: "[listenerother]",
    hostListeners: const {"window:domEvent": "onEvent(\$event.type)"})
class DirectiveListeningDomEventOther {
  String eventType;
  int counter;
  DirectiveListeningDomEventOther() {
    this.eventType = "";
  }
  onEvent(String eventType) {
    globalCounter++;
    this.eventType = "other_" + eventType;
  }
}
@Directive(
    selector: "[listenerprevent]",
    hostListeners: const {"click": "onEvent(\$event)"})
class DirectiveListeningDomEventPrevent {
  onEvent(event) {
    return false;
  }
}
@Directive(
    selector: "[listenernoprevent]",
    hostListeners: const {"click": "onEvent(\$event)"})
class DirectiveListeningDomEventNoPrevent {
  onEvent(event) {
    return true;
  }
}
@Directive(selector: "[id]", properties: const {"id": "id"})
class IdDir {
  String id;
}
@Directive(selector: "[static]")
class NeedsAttribute {
  var typeAttribute;
  var titleAttribute;
  var fooAttribute;
  NeedsAttribute(@Attribute("type") String typeAttribute,
      @Attribute("title") String titleAttribute,
      @Attribute("foo") String fooAttribute) {
    this.typeAttribute = typeAttribute;
    this.titleAttribute = titleAttribute;
    this.fooAttribute = fooAttribute;
  }
}
@Directive(selector: "[public-api]")
class PublicApi {}
@Directive(selector: "[private-impl]")
class PrivateImpl extends PublicApi {}
@Directive(selector: "[needs-public-api]")
class NeedsPublicApi {
  NeedsPublicApi(@Parent() PublicApi api) {
    expect(api is PrivateImpl).toBe(true);
  }
}
class ParentInterface {
  String message;
  ParentInterface() {
    this.message = "ParentInterface";
  }
}
@Component(selector: "parent", publishAs: const [ParentInterface])
@View(template: '''<child></child>''', directives: const [ChildComponent])
class ParentComponent extends ParentInterface {
  String message;
  ParentComponent() : super() {
    /* super call moved to initializer */;
    this.message = "Parent";
  }
}
@Component(
    injectables: const [ParentInterface],
    selector: "recursive-parent",
    publishAs: const [ParentInterface])
@View(
    template: '''{{parentService.message}},<child></child>''',
    directives: const [ChildComponent])
class RecursiveParentComponent extends ParentInterface {
  ParentInterface parentService;
  String message;
  RecursiveParentComponent(ParentInterface parentService) : super() {
    /* super call moved to initializer */;
    this.message = "RecursiveParent";
    this.parentService = parentService;
  }
}
@Component(selector: "dynamic-parent", publishAs: const [ParentInterface])
class DynamicParentComponent extends ParentInterface {
  String message;
  var done;
  DynamicParentComponent(DynamicComponentLoader loader, ElementRef location)
      : super() {
    /* super call moved to initializer */;
    this.message = "DynamicParent";
    this.done = loader.loadIntoExistingLocation(ChildComponent, location);
  }
}
class AppDependency {
  ParentInterface parent;
  AppDependency(ParentInterface p) {
    this.parent = p;
  }
}
@Component(selector: "child", injectables: const [AppDependency])
@View(
    template: '''<div>{{parent.message}}</div>,<div>{{appDependency.parent.message}}</div>''')
class ChildComponent {
  ParentInterface parent;
  AppDependency appDependency;
  ChildComponent(ParentInterface p, AppDependency a) {
    this.parent = p;
    this.appDependency = a;
  }
}
@Directive(
    selector: "[toolbar-vc]", properties: const {"toolbarVc": "toolbarVc"})
class ToolbarViewContainer {
  ViewContainerRef vc;
  ToolbarViewContainer(ViewContainerRef vc) {
    this.vc = vc;
  }
  set toolbarVc(ToolbarPart part) {
    var view = this.vc.create(part.protoViewRef, 0, part.elementRef);
    view.setLocal("toolbarProp", "From toolbar");
  }
}
@Directive(selector: "[toolbarpart]")
class ToolbarPart {
  ProtoViewRef protoViewRef;
  ElementRef elementRef;
  ToolbarPart(ProtoViewRef protoViewRef, ElementRef elementRef) {
    this.elementRef = elementRef;
    this.protoViewRef = protoViewRef;
  }
}
@Component(selector: "toolbar")
@View(
    template: "TOOLBAR(<div *for=\"var part of query\" [toolbar-vc]=\"part\"></div>)",
    directives: const [ToolbarViewContainer, For])
class ToolbarComponent {
  QueryList query;
  String ctxProp;
  ToolbarComponent(@Query(ToolbarPart) QueryList query) {
    this.ctxProp = "hello world";
    this.query = query;
  }
}
