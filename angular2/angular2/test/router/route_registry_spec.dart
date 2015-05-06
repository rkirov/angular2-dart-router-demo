library angular2.test.router.route_registry_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        describe,
        it,
        iit,
        ddescribe,
        expect,
        inject,
        beforeEach,
        SpyObject;
import "package:angular2/src/router/route_registry.dart" show RouteRegistry;
import "package:angular2/src/router/route_config_impl.dart" show RouteConfig;

main() {
  describe("RouteRegistry", () {
    var registry,
        rootHostComponent = new Object();
    beforeEach(() {
      registry = new RouteRegistry();
    });
    it("should match the full URL", () {
      registry.config(
          rootHostComponent, {"path": "/", "component": DummyCompA});
      registry.config(
          rootHostComponent, {"path": "/test", "component": DummyCompB});
      var instruction = registry.recognize("/test", rootHostComponent);
      expect(instruction.getChildInstruction("default").component)
          .toBe(DummyCompB);
    });
    it("should match the full URL recursively", () {
      registry.config(
          rootHostComponent, {"path": "/first", "component": DummyParentComp});
      var instruction = registry.recognize("/first/second", rootHostComponent);
      var parentInstruction = instruction.getChildInstruction("default");
      var childInstruction = parentInstruction.getChildInstruction("default");
      expect(parentInstruction.component).toBe(DummyParentComp);
      expect(childInstruction.component).toBe(DummyCompB);
    });
  });
}
@RouteConfig(const [const {"path": "/second", "component": DummyCompB}])
class DummyParentComp {}
class DummyCompA {}
class DummyCompB {}
