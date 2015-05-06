library benchmarks.src.element_injector.element_injector_benchmark;

import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/di.dart" show Injectable, Injector;
import "package:angular2/src/core/compiler/element_injector.dart"
    show ProtoElementInjector;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, bindAction, microBenchmark;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;

var count = 0;
main() {
  BrowserDomAdapter.makeCurrent();
  var iterations = getIntParameter("iterations");
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  var appInjector = Injector.resolveAndCreate([]);
  var bindings = [A, B, C];
  var proto = new ProtoElementInjector(null, 0, bindings);
  var elementInjector = proto.instantiate(null);
  instantiate() {
    for (var i = 0; i < iterations; ++i) {
      var ei = proto.instantiate(null);
      ei.instantiateDirectives(appInjector, null, null, null);
    }
  }
  instantiateDirectives() {
    for (var i = 0; i < iterations; ++i) {
      elementInjector.clearDirectives();
      elementInjector.instantiateDirectives(appInjector, null, null, null);
    }
  }
  bindAction("#instantiate",
      () => microBenchmark("instantiateAvg", iterations, instantiate));
  bindAction("#instantiateDirectives", () =>
      microBenchmark("instantiateAvg", iterations, instantiateDirectives));
}
@Injectable()
class A {
  A() {
    count++;
  }
}
@Injectable()
class B {
  B() {
    count++;
  }
}
@Injectable()
class C {
  C(A a, B b) {
    count++;
  }
}
