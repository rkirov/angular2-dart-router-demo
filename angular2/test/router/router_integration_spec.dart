library angular2.test.router.router_integration_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        describe,
        expect,
        iit,
        inject,
        it,
        xdescribe,
        xit;
import "package:angular2/src/core/application.dart" show bootstrap;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/di.dart" show bind;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/render/dom/dom_renderer.dart" show DOCUMENT_TOKEN;
import "package:angular2/src/router/route_config_impl.dart" show RouteConfig;
import "package:angular2/router.dart"
    show routerInjectables, Router, RouteParams, RouterOutlet;
import "package:angular2/src/mock/location_mock.dart" show SpyLocation;
import "package:angular2/src/router/location.dart" show Location;

main() {
  describe("router injectables", () {
    var fakeDoc, el, testBindings;
    beforeEach(() {
      fakeDoc = DOM.createHtmlDocument();
      el = DOM.createElement("app-cmp", fakeDoc);
      DOM.appendChild(fakeDoc.body, el);
      testBindings = [
        routerInjectables,
        bind(Location).toClass(SpyLocation),
        bind(DOCUMENT_TOKEN).toValue(fakeDoc)
      ];
    });
    it("should support bootstrap a simple app", inject([AsyncTestCompleter],
        (async) {
      bootstrap(AppCmp, testBindings).then((applicationRef) {
        var router = applicationRef.hostComponent.router;
        router.subscribe((_) {
          expect(el).toHaveText("outer { hello }");
          async.done();
        });
      });
    }));
  });
}
@Component(selector: "hello-cmp")
@View(template: "hello")
class HelloCmp {}
@Component(selector: "app-cmp")
@View(
    template: "outer { <router-outlet></router-outlet> }",
    directives: const [RouterOutlet])
@RouteConfig(const [const {"path": "/", "component": HelloCmp}])
class AppCmp {
  Router router;
  AppCmp(Router router) {
    this.router = router;
  }
}
