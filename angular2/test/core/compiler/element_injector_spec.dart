library angular2.test.core.compiler.element_injector_spec;

import "package:angular2/test_lib.dart"
    show
        describe,
        ddescribe,
        it,
        iit,
        xit,
        xdescribe,
        expect,
        beforeEach,
        SpyObject,
        proxy,
        el;
import "package:angular2/src/facade/lang.dart" show isBlank, isPresent;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, List, StringMapWrapper, iterateListLike;
import "package:angular2/src/core/compiler/element_injector.dart"
    show
        ProtoElementInjector,
        ElementInjector,
        PreBuiltObjects,
        DirectiveBinding,
        TreeNode;
import "package:angular2/src/core/annotations_impl/visibility.dart"
    show Parent, Ancestor;
import "package:angular2/src/core/annotations_impl/di.dart"
    show Attribute, Query;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive, onDestroy;
import "package:angular2/di.dart" show bind, Injector;
import "package:angular2/src/di/annotations_impl.dart" show Optional, Inject;
import "package:angular2/src/core/compiler/view.dart"
    show AppProtoView, AppView;
import "package:angular2/src/core/compiler/view_container_ref.dart"
    show ViewContainerRef;
import "package:angular2/src/core/compiler/view_ref.dart" show ProtoViewRef;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;
import "package:angular2/change_detection.dart"
    show DynamicChangeDetector, ChangeDetectorRef, Parser, Lexer;
import "package:angular2/src/render/api.dart" show ViewRef, Renderer;
import "package:angular2/src/core/compiler/query_list.dart" show QueryList;

class DummyDirective extends Directive {
  DummyDirective({lifecycle, events, hostActions})
      : super(lifecycle: lifecycle, events: events, hostActions: hostActions) {
    /* super call moved to initializer */;
  }
}
@proxy
class DummyView extends SpyObject implements AppView {
  var componentChildViews;
  var changeDetector;
  DummyView() : super() {
    /* super call moved to initializer */;
    this.componentChildViews = [];
    this.changeDetector = null;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
class SimpleDirective {}
class SomeOtherDirective {}
var _constructionCount = 0;
class CountingDirective {
  var count;
  CountingDirective() {
    this.count = _constructionCount;
    _constructionCount += 1;
  }
}
class FancyCountingDirective extends CountingDirective {
  FancyCountingDirective() : super() {
    /* super call moved to initializer */;
  }
}
class NeedsDirective {
  SimpleDirective dependency;
  NeedsDirective(SimpleDirective dependency) {
    this.dependency = dependency;
  }
}
class OptionallyNeedsDirective {
  SimpleDirective dependency;
  OptionallyNeedsDirective(@Optional() SimpleDirective dependency) {
    this.dependency = dependency;
  }
}
class NeedDirectiveFromParent {
  SimpleDirective dependency;
  NeedDirectiveFromParent(@Parent() SimpleDirective dependency) {
    this.dependency = dependency;
  }
}
class NeedDirectiveFromAncestor {
  SimpleDirective dependency;
  NeedDirectiveFromAncestor(@Ancestor() SimpleDirective dependency) {
    this.dependency = dependency;
  }
}
class NeedsService {
  dynamic service;
  NeedsService(@Inject("service") service) {
    this.service = service;
  }
}
class HasEventEmitter {
  var emitter;
  HasEventEmitter() {
    this.emitter = "emitter";
  }
}
class HasHostAction {
  var hostActionName;
  HasHostAction() {
    this.hostActionName = "hostAction";
  }
}
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
class NeedsAttributeNoType {
  var fooAttribute;
  NeedsAttributeNoType(@Attribute("foo") fooAttribute) {
    this.fooAttribute = fooAttribute;
  }
}
class NeedsQuery {
  QueryList query;
  NeedsQuery(@Query(CountingDirective) QueryList query) {
    this.query = query;
  }
}
class NeedsElementRef {
  var elementRef;
  NeedsElementRef(ElementRef ref) {
    this.elementRef = ref;
  }
}
class NeedsViewContainer {
  var viewContainer;
  NeedsViewContainer(ViewContainerRef vc) {
    this.viewContainer = vc;
  }
}
class NeedsProtoViewRef {
  var protoViewRef;
  NeedsProtoViewRef(ProtoViewRef ref) {
    this.protoViewRef = ref;
  }
}
class NeedsChangeDetectorRef {
  var changeDetectorRef;
  NeedsChangeDetectorRef(ChangeDetectorRef cdr) {
    this.changeDetectorRef = cdr;
  }
}
class A_Needs_B {
  A_Needs_B(dep) {}
}
class B_Needs_A {
  B_Needs_A(dep) {}
}
class DirectiveWithDestroy {
  num onDestroyCounter;
  DirectiveWithDestroy() {
    this.onDestroyCounter = 0;
  }
  onDestroy() {
    this.onDestroyCounter++;
  }
}
class TestNode extends TreeNode {
  String message;
  TestNode(TestNode parent, message) : super(parent) {
    /* super call moved to initializer */;
    this.message = message;
  }
  toString() {
    return this.message;
  }
}
// TypeScript erases interfaces, so it has to be a class
class ParentInterface {}
class ParentComponent extends ParentInterface {}
class AppDependency {
  ParentInterface parent;
  AppDependency(ParentInterface p) {
    this.parent = p;
  }
}
class ChildComponent {
  ParentInterface parent;
  AppDependency appDependency;
  ChildComponent(ParentInterface p, AppDependency a) {
    this.parent = p;
    this.appDependency = a;
  }
}
main() {
  var defaultPreBuiltObjects = new PreBuiltObjects(null, null, null);
  var appInjector = Injector.resolveAndCreate([]);
  humanize(tree, List names) {
    var lookupName = (item) => ListWrapper
        .last(ListWrapper.find(names, (pair) => identical(pair[0], item)));
    if (tree.children.length == 0) return lookupName(tree);
    var children = tree.children.map((m) => humanize(m, names));
    return [lookupName(tree), children];
  }
  injector(bindings, [lightDomAppInjector = null, bool isComponent = false,
      preBuiltObjects = null, attributes = null]) {
    if (isBlank(lightDomAppInjector)) lightDomAppInjector = appInjector;
    var proto = new ProtoElementInjector(null, 0, bindings, isComponent);
    proto.attributes = attributes;
    var inj = proto.instantiate(null);
    var preBuilt =
        isPresent(preBuiltObjects) ? preBuiltObjects : defaultPreBuiltObjects;
    inj.instantiateDirectives(lightDomAppInjector, null, preBuilt);
    return inj;
  }
  parentChildInjectors(parentBindings, childBindings,
      [parentPreBuildObjects = null, bool isParentComponent = false]) {
    if (isBlank(parentPreBuildObjects)) parentPreBuildObjects =
        defaultPreBuiltObjects;
    var inj = Injector.resolveAndCreate([]);
    var protoParent =
        new ProtoElementInjector(null, 0, parentBindings, isParentComponent);
    var parent = protoParent.instantiate(null);
    parent.instantiateDirectives(inj, null, parentPreBuildObjects);
    var protoChild =
        new ProtoElementInjector(protoParent, 1, childBindings, false, 1);
    var child = protoChild.instantiate(parent);
    child.instantiateDirectives(inj, null, defaultPreBuiltObjects);
    return child;
  }
  ElementInjector hostShadowInjectors(List hostBindings, List shadowBindings,
      [bool isParentComponent = true, bool isChildComponent = false]) {
    var inj = Injector.resolveAndCreate([]);
    var protoParent =
        new ProtoElementInjector(null, 0, hostBindings, isParentComponent);
    var host = protoParent.instantiate(null);
    host.instantiateDirectives(inj, null, defaultPreBuiltObjects);
    var protoChild = new ProtoElementInjector(
        protoParent, 0, shadowBindings, isChildComponent, 1);
    var shadow = protoChild.instantiate(null);
    shadow.instantiateDirectives(host.getShadowDomAppInjector(), host, null);
    return shadow;
  }
  describe("TreeNodes", () {
    var root, firstParent, lastParent, node;
    /*
      Build a tree of the following shape:
      root
        - p1
          - c1
          - c2
        - p2
          - c3
     */
    beforeEach(() {
      root = new TestNode(null, "root");
      var p1 = firstParent = new TestNode(root, "p1");
      var p2 = lastParent = new TestNode(root, "p2");
      node = new TestNode(p1, "c1");
      new TestNode(p1, "c2");
      new TestNode(p2, "c3");
    });
    // depth-first pre-order.
    walk(node, f) {
      if (isBlank(node)) return f;
      f(node);
      ListWrapper.forEach(node.children, (n) => walk(n, f));
    }
    logWalk(node) {
      var log = "";
      walk(node, (n) {
        log += (log.length != 0 ? ", " : "") + n.toString();
      });
      return log;
    }
    it("should support listing children", () {
      expect(logWalk(root)).toEqual("root, p1, c1, c2, p2, c3");
    });
    it("should support removing the first child node", () {
      firstParent.remove();
      expect(firstParent.parent).toEqual(null);
      expect(logWalk(root)).toEqual("root, p2, c3");
    });
    it("should support removing the last child node", () {
      lastParent.remove();
      expect(logWalk(root)).toEqual("root, p1, c1, c2");
    });
    it("should support moving a node at the end of children", () {
      node.remove();
      root.addChild(node);
      expect(logWalk(root)).toEqual("root, p1, c2, p2, c3, c1");
    });
    it("should support moving a node in the beginning of children", () {
      node.remove();
      lastParent.addChildAfter(node, null);
      expect(logWalk(root)).toEqual("root, p1, c2, p2, c1, c3");
    });
    it("should support moving a node in the middle of children", () {
      node.remove();
      lastParent.addChildAfter(node, firstParent);
      expect(logWalk(root)).toEqual("root, p1, c2, c1, p2, c3");
    });
  });
  describe("ProtoElementInjector", () {
    describe("direct parent", () {
      it("should return parent proto injector when distance is 1", () {
        var distance = 1;
        var protoParent = new ProtoElementInjector(null, 0, []);
        var protoChild =
            new ProtoElementInjector(protoParent, 1, [], false, distance);
        expect(protoChild.directParent()).toEqual(protoParent);
      });
      it("should return null otherwise", () {
        var distance = 2;
        var protoParent = new ProtoElementInjector(null, 0, []);
        var protoChild =
            new ProtoElementInjector(protoParent, 1, [], false, distance);
        expect(protoChild.directParent()).toEqual(null);
      });
      it("should allow for direct access using getDirectiveBindingAtIndex", () {
        var binding = DirectiveBinding.createFromBinding(
            bind(SimpleDirective).toClass(SimpleDirective), null);
        var proto = new ProtoElementInjector(null, 0, [binding]);
        expect(proto.getDirectiveBindingAtIndex(0))
            .toBeAnInstanceOf(DirectiveBinding);
        expect(() => proto.getDirectiveBindingAtIndex(-1))
            .toThrowError("Index -1 is out-of-bounds.");
        expect(() => proto.getDirectiveBindingAtIndex(10))
            .toThrowError("Index 10 is out-of-bounds.");
      });
    });
    describe("event emitters", () {
      it("should return a list of event accessors", () {
        var binding = DirectiveBinding.createFromType(
            HasEventEmitter, new DummyDirective(events: ["emitter"]));
        var inj = new ProtoElementInjector(null, 0, [binding]);
        expect(inj.eventEmitterAccessors.length).toEqual(1);
        var accessor = inj.eventEmitterAccessors[0][0];
        expect(accessor.eventName).toEqual("emitter");
        expect(accessor.getter(new HasEventEmitter())).toEqual("emitter");
      });
      it("should return a list of hostAction accessors", () {
        var binding = DirectiveBinding.createFromType(HasEventEmitter,
            new DummyDirective(hostActions: {"hostActionName": "onAction"}));
        var inj = new ProtoElementInjector(null, 0, [binding]);
        expect(inj.hostActionAccessors.length).toEqual(1);
        var accessor = inj.hostActionAccessors[0][0];
        expect(accessor.actionExpression).toEqual("onAction");
        expect(accessor.getter(new HasHostAction())).toEqual("hostAction");
      });
    });
  });
  describe("ElementInjector", () {
    describe("instantiate", () {
      it("should create an element injector", () {
        var protoParent = new ProtoElementInjector(null, 0, []);
        var protoChild1 = new ProtoElementInjector(protoParent, 1, []);
        var protoChild2 = new ProtoElementInjector(protoParent, 2, []);
        var p = protoParent.instantiate(null);
        var c1 = protoChild1.instantiate(p);
        var c2 = protoChild2.instantiate(p);
        expect(humanize(p, [[p, "parent"], [c1, "child1"], [c2, "child2"]]))
            .toEqual(["parent", ["child1", "child2"]]);
      });
      describe("direct parent", () {
        it("should return parent injector when distance is 1", () {
          var distance = 1;
          var protoParent = new ProtoElementInjector(null, 0, []);
          var protoChild =
              new ProtoElementInjector(protoParent, 1, [], false, distance);
          var p = protoParent.instantiate(null);
          var c = protoChild.instantiate(p);
          expect(c.directParent()).toEqual(p);
        });
        it("should return null otherwise", () {
          var distance = 2;
          var protoParent = new ProtoElementInjector(null, 0, []);
          var protoChild =
              new ProtoElementInjector(protoParent, 1, [], false, distance);
          var p = protoParent.instantiate(null);
          var c = protoChild.instantiate(p);
          expect(c.directParent()).toEqual(null);
        });
      });
    });
    describe("hasBindings", () {
      it("should be true when there are bindings", () {
        var p = new ProtoElementInjector(null, 0, [SimpleDirective]);
        expect(p.hasBindings).toBeTruthy();
      });
      it("should be false otherwise", () {
        var p = new ProtoElementInjector(null, 0, []);
        expect(p.hasBindings).toBeFalsy();
      });
    });
    describe("hasInstances", () {
      it("should be false when no directives are instantiated", () {
        expect(injector([]).hasInstances()).toBe(false);
      });
      it("should be true when directives are instantiated", () {
        expect(injector([SimpleDirective]).hasInstances()).toBe(true);
      });
    });
    describe("instantiateDirectives", () {
      it("should instantiate directives that have no dependencies", () {
        var inj = injector([SimpleDirective]);
        expect(inj.get(SimpleDirective)).toBeAnInstanceOf(SimpleDirective);
      });
      it("should instantiate directives that depend on other directives", () {
        var inj = injector([SimpleDirective, NeedsDirective]);
        var d = inj.get(NeedsDirective);
        expect(d).toBeAnInstanceOf(NeedsDirective);
        expect(d.dependency).toBeAnInstanceOf(SimpleDirective);
      });
      it("should instantiate directives that depend on app services", () {
        var appInjector =
            Injector.resolveAndCreate([bind("service").toValue("service")]);
        var inj = injector([NeedsService], appInjector);
        var d = inj.get(NeedsService);
        expect(d).toBeAnInstanceOf(NeedsService);
        expect(d.service).toEqual("service");
      });
      it("should instantiate directives that depend on pre built objects", () {
        var protoView = new AppProtoView(null, null, null, null, null);
        var inj = injector([NeedsProtoViewRef], null, false,
            new PreBuiltObjects(null, null, protoView));
        expect(inj.get(NeedsProtoViewRef).protoViewRef)
            .toEqual(new ProtoViewRef(protoView));
      });
      it("should instantiate directives that depend on the containing component",
          () {
        var directiveBinding =
            DirectiveBinding.createFromType(SimpleDirective, new Component());
        var shadow = hostShadowInjectors([directiveBinding], [NeedsDirective]);
        var d = shadow.get(NeedsDirective);
        expect(d).toBeAnInstanceOf(NeedsDirective);
        expect(d.dependency).toBeAnInstanceOf(SimpleDirective);
      });
      it("should not instantiate directives that depend on other directives in the containing component's ElementInjector",
          () {
        var directiveBinding = DirectiveBinding.createFromType(
            SomeOtherDirective, new Component());
        expect(() {
          hostShadowInjectors(
              [directiveBinding, SimpleDirective], [NeedsDirective]);
        }).toThrowError(
            "No provider for SimpleDirective! (NeedsDirective -> SimpleDirective)");
      });
      it("should instantiate component directives that depend on app services in the shadow app injector",
          () {
        var directiveAnnotation =
            new Component(injectables: [bind("service").toValue("service")]);
        var componentDirective =
            DirectiveBinding.createFromType(NeedsService, directiveAnnotation);
        var inj = injector([componentDirective], null, true);
        var d = inj.get(NeedsService);
        expect(d).toBeAnInstanceOf(NeedsService);
        expect(d.service).toEqual("service");
      });
      it("should not instantiate other directives that depend on app services in the shadow app injector",
          () {
        var directiveAnnotation =
            new Component(injectables: [bind("service").toValue("service")]);
        var componentDirective = DirectiveBinding.createFromType(
            SimpleDirective, directiveAnnotation);
        expect(() {
          injector([componentDirective, NeedsService], null);
        }).toThrowError("No provider for service! (NeedsService -> service)");
      });
      it("should return app services", () {
        var appInjector =
            Injector.resolveAndCreate([bind("service").toValue("service")]);
        var inj = injector([], appInjector);
        expect(inj.get("service")).toEqual("service");
      });
      it("should get directives from parent", () {
        var child =
            parentChildInjectors([SimpleDirective], [NeedDirectiveFromParent]);
        var d = child.get(NeedDirectiveFromParent);
        expect(d).toBeAnInstanceOf(NeedDirectiveFromParent);
        expect(d.dependency).toBeAnInstanceOf(SimpleDirective);
      });
      it("should not return parent's directives on self", () {
        expect(() {
          injector([SimpleDirective, NeedDirectiveFromParent]);
        }).toThrowError(new RegExp("No provider for SimpleDirective"));
      });
      it("should get directives from ancestor", () {
        var child = parentChildInjectors(
            [SimpleDirective], [NeedDirectiveFromAncestor]);
        var d = child.get(NeedDirectiveFromAncestor);
        expect(d).toBeAnInstanceOf(NeedDirectiveFromAncestor);
        expect(d.dependency).toBeAnInstanceOf(SimpleDirective);
      });
      it("should throw when no SimpleDirective found", () {
        expect(() => injector([NeedDirectiveFromParent])).toThrowError(
            "No provider for SimpleDirective! (NeedDirectiveFromParent -> SimpleDirective)");
      });
      it("should inject null when no directive found", () {
        var inj = injector([OptionallyNeedsDirective]);
        var d = inj.get(OptionallyNeedsDirective);
        expect(d.dependency).toEqual(null);
      });
      it("should accept SimpleDirective bindings instead of SimpleDirective types",
          () {
        var inj = injector([
          DirectiveBinding.createFromBinding(
              bind(SimpleDirective).toClass(SimpleDirective), null)
        ]);
        expect(inj.get(SimpleDirective)).toBeAnInstanceOf(SimpleDirective);
      });
      it("should allow for direct access using getDirectiveAtIndex", () {
        var inj = injector([
          DirectiveBinding.createFromBinding(
              bind(SimpleDirective).toClass(SimpleDirective), null)
        ]);
        expect(inj.getDirectiveAtIndex(0)).toBeAnInstanceOf(SimpleDirective);
        expect(() => inj.getDirectiveAtIndex(-1))
            .toThrowError("Index -1 is out-of-bounds.");
        expect(() => inj.getDirectiveAtIndex(10))
            .toThrowError("Index 10 is out-of-bounds.");
      });
      it("should handle cyclic dependencies", () {
        expect(() {
          var bAneedsB =
              bind(A_Needs_B).toFactory((a) => new A_Needs_B(a), [B_Needs_A]);
          var bBneedsA =
              bind(B_Needs_A).toFactory((a) => new B_Needs_A(a), [A_Needs_B]);
          injector([
            DirectiveBinding.createFromBinding(bAneedsB, null),
            DirectiveBinding.createFromBinding(bBneedsA, null)
          ]);
        }).toThrowError("Cannot instantiate cyclic dependency! " +
            "(A_Needs_B -> B_Needs_A -> A_Needs_B)");
      });
      it("should call onDestroy on directives subscribed to this event", () {
        var inj = injector([
          DirectiveBinding.createFromType(
              DirectiveWithDestroy, new DummyDirective(lifecycle: [onDestroy]))
        ]);
        var destroy = inj.get(DirectiveWithDestroy);
        inj.clearDirectives();
        expect(destroy.onDestroyCounter).toBe(1);
      });
      it("should publish component to its children via app injector when requested",
          () {
        var parentDirective =
            new Component(selector: "parent", publishAs: [ParentInterface]);
        var parentBinding =
            DirectiveBinding.createFromType(ParentComponent, parentDirective);
        var childDirective =
            new Component(selector: "child", injectables: [AppDependency]);
        var childBinding =
            DirectiveBinding.createFromType(ChildComponent, childDirective);
        var child =
            hostShadowInjectors([parentBinding], [childBinding], true, true);
        var d = child.get(ChildComponent);
        // Verify that the child component can inject parent via interface binding
        expect(d).toBeAnInstanceOf(ChildComponent);
        expect(d.parent).toBeAnInstanceOf(ParentComponent);
        // Verify that the binding is available down the dependency tree
        expect(d.appDependency.parent).toBeAnInstanceOf(ParentComponent);
        expect(d.parent).toBe(d.appDependency.parent);
      });
    });
    describe("dynamicallyCreateComponent", () {
      it("should create a component dynamically", () {
        var inj = injector([]);
        inj.dynamicallyCreateComponent(
            DirectiveBinding.createFromType(SimpleDirective, null), null);
        expect(inj.getDynamicallyLoadedComponent())
            .toBeAnInstanceOf(SimpleDirective);
        expect(inj.get(SimpleDirective)).toBeAnInstanceOf(SimpleDirective);
      });
      it("should inject parent dependencies into the dynamically-loaded component",
          () {
        var inj = parentChildInjectors([SimpleDirective], []);
        inj.dynamicallyCreateComponent(
            DirectiveBinding.createFromType(NeedDirectiveFromAncestor, null),
            null);
        expect(inj.getDynamicallyLoadedComponent())
            .toBeAnInstanceOf(NeedDirectiveFromAncestor);
        expect(inj.getDynamicallyLoadedComponent().dependency)
            .toBeAnInstanceOf(SimpleDirective);
      });
      it("should not inject the proxy component into the children of the dynamically-loaded component",
          () {
        var injWithDynamicallyLoadedComponent = injector([SimpleDirective]);
        injWithDynamicallyLoadedComponent.dynamicallyCreateComponent(
            DirectiveBinding.createFromType(SomeOtherDirective, null), null);
        var shadowDomProtoInjector = new ProtoElementInjector(
            null, 0, [NeedDirectiveFromAncestor], false);
        var shadowDomInj = shadowDomProtoInjector.instantiate(null);
        expect(() => shadowDomInj.instantiateDirectives(appInjector,
                injWithDynamicallyLoadedComponent, defaultPreBuiltObjects))
            .toThrowError(new RegExp("No provider for SimpleDirective"));
      });
      it("should not inject the dynamically-loaded component into directives on the same element",
          () {
        var dynamicComp = DirectiveBinding.createFromType(
            SomeOtherDirective, new Component());
        var proto = new ProtoElementInjector(
            null, 0, [dynamicComp, NeedsDirective], true);
        var inj = proto.instantiate(null);
        inj.dynamicallyCreateComponent(
            DirectiveBinding.createFromType(SimpleDirective, null), null);
        var error = null;
        try {
          inj.instantiateDirectives(Injector.resolveAndCreate([]), null, null);
        } catch (e) {
          error = e;
        }
        expect(error.message).toEqual(
            "No provider for SimpleDirective! (NeedsDirective -> SimpleDirective)");
      });
      it("should inject the dynamically-loaded component into the children of the dynamically-loaded component",
          () {
        var componentDirective =
            DirectiveBinding.createFromType(SimpleDirective, null);
        var injWithDynamicallyLoadedComponent = injector([]);
        injWithDynamicallyLoadedComponent.dynamicallyCreateComponent(
            componentDirective, null);
        var shadowDomProtoInjector = new ProtoElementInjector(
            null, 0, [NeedDirectiveFromAncestor], false);
        var shadowDomInjector = shadowDomProtoInjector.instantiate(null);
        shadowDomInjector.instantiateDirectives(appInjector,
            injWithDynamicallyLoadedComponent, defaultPreBuiltObjects);
        expect(shadowDomInjector.get(NeedDirectiveFromAncestor))
            .toBeAnInstanceOf(NeedDirectiveFromAncestor);
        expect(shadowDomInjector.get(NeedDirectiveFromAncestor).dependency)
            .toBeAnInstanceOf(SimpleDirective);
      });
      it("should remove the dynamically-loaded component when dehydrating", () {
        var inj = injector([]);
        inj.dynamicallyCreateComponent(DirectiveBinding.createFromType(
            DirectiveWithDestroy,
            new DummyDirective(lifecycle: [onDestroy])), null);
        var dir = inj.getDynamicallyLoadedComponent();
        inj.clearDirectives();
        expect(inj.getDynamicallyLoadedComponent()).toBe(null);
        expect(dir.onDestroyCounter).toBe(1);
        inj.instantiateDirectives(null, null, null);
        expect(inj.getDynamicallyLoadedComponent()).toBe(null);
      });
      it("should inject services of the dynamically-loaded component", () {
        var inj = injector([]);
        var appInjector =
            Injector.resolveAndCreate([bind("service").toValue("Service")]);
        inj.dynamicallyCreateComponent(
            DirectiveBinding.createFromType(NeedsService, null), appInjector);
        expect(inj.getDynamicallyLoadedComponent().service).toEqual("Service");
      });
    });
    describe("static attributes", () {
      it("should be injectable", () {
        var attributes = MapWrapper.create();
        MapWrapper.set(attributes, "type", "text");
        MapWrapper.set(attributes, "title", "");
        var inj = injector([NeedsAttribute], null, false, null, attributes);
        var needsAttribute = inj.get(NeedsAttribute);
        expect(needsAttribute.typeAttribute).toEqual("text");
        expect(needsAttribute.titleAttribute).toEqual("");
        expect(needsAttribute.fooAttribute).toEqual(null);
      });
      it("should be injectable without type annotation", () {
        var attributes = MapWrapper.create();
        MapWrapper.set(attributes, "foo", "bar");
        var inj =
            injector([NeedsAttributeNoType], null, false, null, attributes);
        var needsAttribute = inj.get(NeedsAttributeNoType);
        expect(needsAttribute.fooAttribute).toEqual("bar");
      });
    });
    describe("refs", () {
      it("should inject ElementRef", () {
        var inj = injector([NeedsElementRef]);
        expect(inj.get(NeedsElementRef).elementRef)
            .toBeAnInstanceOf(ElementRef);
      });
      it("should inject ChangeDetectorRef", () {
        var cd = new DynamicChangeDetector(null, null, null, [], []);
        var view = new DummyView();
        var childView = new DummyView();
        childView.changeDetector = cd;
        view.componentChildViews = [childView];
        var inj = injector([NeedsChangeDetectorRef], null, false,
            new PreBuiltObjects(null, view, null));
        expect(inj.get(NeedsChangeDetectorRef).changeDetectorRef).toBe(cd.ref);
      });
      it("should inject ViewContainerRef", () {
        var inj = injector([NeedsViewContainer]);
        expect(inj.get(NeedsViewContainer).viewContainer)
            .toBeAnInstanceOf(ViewContainerRef);
      });
      it("should inject ProtoViewRef", () {
        var protoView = new AppProtoView(null, null, null, null, null);
        var inj = injector([NeedsProtoViewRef], null, false,
            new PreBuiltObjects(null, null, protoView));
        expect(inj.get(NeedsProtoViewRef).protoViewRef)
            .toEqual(new ProtoViewRef(protoView));
      });
      it("should throw if there is no ProtoViewRef", () {
        expect(() => injector([NeedsProtoViewRef])).toThrowError(
            "No provider for ProtoViewRef! (NeedsProtoViewRef -> ProtoViewRef)");
      });
    });
    describe("directive queries", () {
      var preBuildObjects = defaultPreBuiltObjects;
      beforeEach(() {
        _constructionCount = 0;
      });
      expectDirectives(query, type, expectedIndex) {
        var currentCount = 0;
        iterateListLike(query, (i) {
          expect(i).toBeAnInstanceOf(type);
          expect(i.count).toBe(expectedIndex[currentCount]);
          currentCount += 1;
        });
      }
      it("should be injectable", () {
        var inj = injector([NeedsQuery], null, false, preBuildObjects);
        expect(inj.get(NeedsQuery).query).toBeAnInstanceOf(QueryList);
      });
      it("should contain directives on the same injector", () {
        var inj = injector(
            [NeedsQuery, CountingDirective], null, false, preBuildObjects);
        expectDirectives(inj.get(NeedsQuery).query, CountingDirective, [0]);
      });
      // Dart's restriction on static types in (a is A) makes this feature hard to implement.

      // Current proposal is to add second parameter the Query constructor to take a

      // comparison function to support user-defined definition of matching.

      //it('should support super class directives', () => {

      //  var inj = injector([NeedsQuery, FancyCountingDirective], null, null, preBuildObjects);

      //

      //  expectDirectives(inj.get(NeedsQuery).query, FancyCountingDirective, [0]);

      //});
      it("should contain directives on the same and a child injector in construction order",
          () {
        var protoParent =
            new ProtoElementInjector(null, 0, [NeedsQuery, CountingDirective]);
        var protoChild =
            new ProtoElementInjector(protoParent, 1, [CountingDirective]);
        var parent = protoParent.instantiate(null);
        var child = protoChild.instantiate(parent);
        parent.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        expectDirectives(
            parent.get(NeedsQuery).query, CountingDirective, [0, 1]);
      });
      it("should reflect unlinking an injector", () {
        var protoParent =
            new ProtoElementInjector(null, 0, [NeedsQuery, CountingDirective]);
        var protoChild =
            new ProtoElementInjector(protoParent, 1, [CountingDirective]);
        var parent = protoParent.instantiate(null);
        var child = protoChild.instantiate(parent);
        parent.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child.unlink();
        expectDirectives(parent.get(NeedsQuery).query, CountingDirective, [0]);
      });
      it("should reflect moving an injector as a last child", () {
        var protoParent =
            new ProtoElementInjector(null, 0, [NeedsQuery, CountingDirective]);
        var protoChild1 =
            new ProtoElementInjector(protoParent, 1, [CountingDirective]);
        var protoChild2 =
            new ProtoElementInjector(protoParent, 1, [CountingDirective]);
        var parent = protoParent.instantiate(null);
        var child1 = protoChild1.instantiate(parent);
        var child2 = protoChild2.instantiate(parent);
        parent.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child1.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child2.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child1.unlink();
        child1.link(parent);
        var queryList = parent.get(NeedsQuery).query;
        expectDirectives(queryList, CountingDirective, [0, 2, 1]);
      });
      it("should reflect moving an injector as a first child", () {
        var protoParent =
            new ProtoElementInjector(null, 0, [NeedsQuery, CountingDirective]);
        var protoChild1 =
            new ProtoElementInjector(protoParent, 1, [CountingDirective]);
        var protoChild2 =
            new ProtoElementInjector(protoParent, 1, [CountingDirective]);
        var parent = protoParent.instantiate(null);
        var child1 = protoChild1.instantiate(parent);
        var child2 = protoChild2.instantiate(parent);
        parent.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child1.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child2.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child2.unlink();
        child2.linkAfter(parent, null);
        var queryList = parent.get(NeedsQuery).query;
        expectDirectives(queryList, CountingDirective, [0, 2, 1]);
      });
      it("should support two concurrent queries for the same directive", () {
        var protoGrandParent = new ProtoElementInjector(null, 0, [NeedsQuery]);
        var protoParent = new ProtoElementInjector(null, 0, [NeedsQuery]);
        var protoChild =
            new ProtoElementInjector(protoParent, 1, [CountingDirective]);
        var grandParent = protoGrandParent.instantiate(null);
        var parent = protoParent.instantiate(grandParent);
        var child = protoChild.instantiate(parent);
        grandParent.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        parent.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        child.instantiateDirectives(
            Injector.resolveAndCreate([]), null, preBuildObjects);
        var queryList1 = grandParent.get(NeedsQuery).query;
        var queryList2 = parent.get(NeedsQuery).query;
        expectDirectives(queryList1, CountingDirective, [0]);
        expectDirectives(queryList2, CountingDirective, [0]);
        child.unlink();
        expectDirectives(queryList1, CountingDirective, []);
        expectDirectives(queryList2, CountingDirective, []);
      });
    });
  });
}
class ContextWithHandler {
  var handler;
  ContextWithHandler(handler) {
    this.handler = handler;
  }
}
class FakeRenderer extends Renderer {
  List log;
  FakeRenderer() : super() {
    /* super call moved to initializer */;
    this.log = [];
  }
  setElementProperty(viewRef, elementIndex, propertyName, value) {
    ListWrapper.push(this.log, [viewRef, elementIndex, propertyName, value]);
  }
}
