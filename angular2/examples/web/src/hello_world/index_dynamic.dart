library examples.src.hello_world.index_dynamic;

import "index_common.dart" show HelloCmp;
import "package:angular2/angular2.dart" show bootstrap;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;

main() {
  // This entry point is not transformed and exists for testing purposes.
  // See index.js for an explanation.
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  bootstrap(HelloCmp);
}
