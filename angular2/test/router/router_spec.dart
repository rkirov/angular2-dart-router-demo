library angular2.test.router.router_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        describe,
        proxy,
        it,
        iit,
        ddescribe,
        expect,
        inject,
        beforeEach,
        beforeEachBindings,
        SpyObject;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/router/router.dart" show Router, RootRouter;
import "package:angular2/src/router/pipeline.dart" show Pipeline;
import "package:angular2/src/router/router_outlet.dart" show RouterOutlet;
import "package:angular2/src/mock/location_mock.dart" show SpyLocation;
import "package:angular2/src/router/location.dart" show Location;
import "package:angular2/src/router/route_registry.dart" show RouteRegistry;
import "package:angular2/src/core/compiler/directive_metadata_reader.dart"
    show DirectiveMetadataReader;
import "package:angular2/di.dart" show bind;

main() {
  describe("Router", () {
    var router, location;
    beforeEachBindings(() => [
      Pipeline,
      RouteRegistry,
      DirectiveMetadataReader,
      bind(Location).toClass(SpyLocation),
      bind(Router).toFactory((registry, pipeline, location) {
        return new RootRouter(registry, pipeline, location, AppCmp);
      }, [RouteRegistry, Pipeline, Location])
    ]);
    beforeEach(inject([Router, Location], (rtr, loc) {
      router = rtr;
      location = loc;
    }));
    it("should navigate based on the initial URL state", inject(
        [AsyncTestCompleter], (async) {
      var outlet = makeDummyRef();
      router
          .config({"path": "/", "component": "Index"})
          .then((_) => router.registerOutlet(outlet))
          .then((_) {
        expect(outlet.spy("activate")).toHaveBeenCalled();
        expect(location.urlChanges).toEqual([]);
        async.done();
      });
    }));
    it("should activate viewports and update URL on navigate", inject(
        [AsyncTestCompleter], (async) {
      var outlet = makeDummyRef();
      router.registerOutlet(outlet).then((_) {
        return router.config({"path": "/a", "component": "A"});
      }).then((_) => router.navigate("/a")).then((_) {
        expect(outlet.spy("activate")).toHaveBeenCalled();
        expect(location.urlChanges).toEqual(["/a"]);
        async.done();
      });
    }));
    it("should navigate after being configured", inject([AsyncTestCompleter],
        (async) {
      var outlet = makeDummyRef();
      router
          .registerOutlet(outlet)
          .then((_) => router.navigate("/a"))
          .then((_) {
        expect(outlet.spy("activate")).not.toHaveBeenCalled();
        return router.config({"path": "/a", "component": "A"});
      }).then((_) {
        expect(outlet.spy("activate")).toHaveBeenCalled();
        async.done();
      });
    }));
  });
}
@proxy
class DummyOutletRef extends SpyObject implements RouterOutlet {
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
makeDummyRef() {
  var ref = new DummyOutletRef();
  ref.spy("activate").andCallFake((_) => PromiseWrapper.resolve(true));
  ref.spy("canActivate").andCallFake((_) => PromiseWrapper.resolve(true));
  ref.spy("canDeactivate").andCallFake((_) => PromiseWrapper.resolve(true));
  ref.spy("deactivate").andCallFake((_) => PromiseWrapper.resolve(true));
  return ref;
}
class AppCmp {}
