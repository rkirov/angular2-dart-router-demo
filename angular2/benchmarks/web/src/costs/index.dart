library benchmarks.src.costs.index;

import "package:angular2/angular2.dart"
    show bootstrap, DynamicComponentLoader, ElementRef;
import "package:angular2/src/core/life_cycle/life_cycle.dart" show LifeCycle;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, bindAction;
import "package:angular2/directives.dart"
    show
        If,
        For; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

var testList = null;
main() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  var size = getIntParameter("size");
  testList = ListWrapper.createFixedSize(size);
  bootstrap(AppComponent).then((ref) {
    var injector = ref.injector;
    AppComponent app = injector.get(AppComponent);
    var lifeCycle = injector.get(LifeCycle);
    bindAction("#reset", () {
      app.reset();
      lifeCycle.tick();
    }); // Baseline (plain components)
    bindAction("#createPlainComponents", () {
      app.createPlainComponents();
      lifeCycle.tick();
    }); // Components with decorators
    bindAction("#createComponentsWithDirectives", () {
      app.createComponentsWithDirectives();
      lifeCycle.tick();
    }); // Components with decorators
    bindAction("#createDynamicComponents", () {
      app.createDynamicComponents();
      lifeCycle.tick();
    });
  });
}
@Component(selector: "app")
@View(
    directives: const [If, For, DummyComponent, DummyDirective, DynamicDummy],
    template: '''
    <div *if="testingPlainComponents">
      <dummy *for="#i of list"></dummy>
    </div>

    <div *if="testingWithDirectives">
      <dummy dummy-decorator *for="#i of list"></dummy>
    </div>

    <div *if="testingDynamicComponents">
      <dynamic-dummy *for="#i of list"></dynamic-dummy>
    </div>
  ''')
class AppComponent {
  List list;
  bool testingPlainComponents;
  bool testingWithDirectives;
  bool testingDynamicComponents;
  AppComponent() {
    this.reset();
  }
  void reset() {
    this.list = [];
    this.testingPlainComponents = false;
    this.testingWithDirectives = false;
    this.testingDynamicComponents = false;
  }
  void createPlainComponents() {
    this.list = testList;
    this.testingPlainComponents = true;
  }
  void createComponentsWithDirectives() {
    this.list = testList;
    this.testingWithDirectives = true;
  }
  void createDynamicComponents() {
    this.list = testList;
    this.testingDynamicComponents = true;
  }
}
@Component(selector: "dummy")
@View(template: '''<div></div>''')
class DummyComponent {}
@Directive(selector: "[dummy-decorator]")
class DummyDirective {}
@Component(selector: "dynamic-dummy")
class DynamicDummy {
  DynamicDummy(DynamicComponentLoader loader, ElementRef location) {
    loader.loadIntoExistingLocation(DummyComponent, location);
  }
}
