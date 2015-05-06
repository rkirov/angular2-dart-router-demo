library benchmarks.src.di.di_benchmark;

import "package:angular2/di.dart" show Injectable, Injector, Key, bind;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, bindAction, microBenchmark;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;

var count = 0;
setupReflector() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
}
main() {
  BrowserDomAdapter.makeCurrent();
  var iterations = getIntParameter("iterations");
  setupReflector();
  var bindings = [A, B, C, D, E];
  var injector = Injector.resolveAndCreate(bindings);
  var D_KEY = Key.get(D);
  var E_KEY = Key.get(E);
  var childInjector = injector
      .resolveAndCreateChild([])
      .resolveAndCreateChild([])
      .resolveAndCreateChild([])
      .resolveAndCreateChild([])
      .resolveAndCreateChild([]);
  var variousBindings = [A, bind(B).toClass(C), [D, [E]], bind(F).toValue(6)];
  var variousBindingsResolved = Injector.resolve(variousBindings);
  getByToken() {
    for (var i = 0; i < iterations; ++i) {
      injector.get(D);
      injector.get(E);
    }
  }
  getByKey() {
    for (var i = 0; i < iterations; ++i) {
      injector.get(D_KEY);
      injector.get(E_KEY);
    }
  }
  getChild() {
    for (var i = 0; i < iterations; ++i) {
      childInjector.get(D);
      childInjector.get(E);
    }
  }
  instantiate() {
    for (var i = 0; i < iterations; ++i) {
      var child = injector.resolveAndCreateChild([E]);
      child.get(E);
    }
  } /**
   * Creates an injector with a variety of binding types.
   */
  createVariety() {
    for (var i = 0; i < iterations; ++i) {
      Injector.resolveAndCreate(variousBindings);
    }
  } /**
   * Same as [createVariety] but resolves bindings ahead of time.
   */
  createVarietyResolved() {
    for (var i = 0; i < iterations; ++i) {
      Injector.fromResolvedBindings(variousBindingsResolved);
    }
  }
  bindAction(
      "#getByToken", () => microBenchmark("injectAvg", iterations, getByToken));
  bindAction(
      "#getByKey", () => microBenchmark("injectAvg", iterations, getByKey));
  bindAction(
      "#getChild", () => microBenchmark("injectAvg", iterations, getChild));
  bindAction("#instantiate",
      () => microBenchmark("injectAvg", iterations, instantiate));
  bindAction("#createVariety",
      () => microBenchmark("injectAvg", iterations, createVariety));
  bindAction("#createVarietyResolved",
      () => microBenchmark("injectAvg", iterations, createVarietyResolved));
}
@Injectable()
class A {
  A() {
    count++;
  }
}
@Injectable()
class B {
  B(A a) {
    count++;
  }
}
@Injectable()
class C {
  C(B b) {
    count++;
  }
}
@Injectable()
class D {
  D(C c, B b) {
    count++;
  }
}
@Injectable()
class E {
  E(D d, C c) {
    count++;
  }
}
@Injectable()
class F {
  F(E e, D d) {
    count++;
  }
}
