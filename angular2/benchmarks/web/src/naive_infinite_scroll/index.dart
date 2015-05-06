library benchmarks.src.naive_infinite_scroll.index;

import "package:angular2/src/facade/collection.dart" show MapWrapper;
import "package:angular2/angular2.dart" show bootstrap;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "app.dart" show App;
import "package:angular2/src/core/compiler/view_pool.dart"
    show APP_VIEW_POOL_CAPACITY;
import "package:angular2/di.dart" show bind;

main() {
  setupReflector();
  bootstrap(App, createBindings());
}
List createBindings() {
  return [bind(APP_VIEW_POOL_CAPACITY).toValue(100000)];
}
setupReflector() {
  reflector.reflectionCapabilities =
      new ReflectionCapabilities(); // TODO(kegluneq): Generate this.
  reflector.registerSetters({
    "style": (o, m) {
      // HACK
      MapWrapper.forEach(m, (v, k) {
        o.style.setProperty(k, v);
      });
    }
  });
  reflector.registerMethods({
    "onScroll": (o, args) {
      // HACK
      o.onScroll(args[0]);
    },
    "setStage": (o, args) => o.setStage(args[0])
  });
}
