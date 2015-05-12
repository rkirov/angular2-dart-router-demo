library angular2.src.router.router_outlet;

import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/lang.dart" show isBlank;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/src/core/annotations_impl/di.dart" show Attribute;
import "package:angular2/core.dart" show Compiler, ViewContainerRef;
import "package:angular2/di.dart" show Injector, bind;
import "router.dart" as routerMod;
import "instruction.dart" show Instruction, RouteParams;

@Directive(selector: "router-outlet")
class RouterOutlet {
  Compiler _compiler;
  Injector _injector;
  routerMod.Router _router;
  ViewContainerRef _viewContainer;
  RouterOutlet(ViewContainerRef viewContainer, Compiler compiler,
      routerMod.Router router, Injector injector,
      @Attribute("name") String nameAttr) {
    if (isBlank(nameAttr)) {
      nameAttr = "default";
    }
    this._router = router;
    this._viewContainer = viewContainer;
    this._compiler = compiler;
    this._injector = injector;
    this._router.registerOutlet(this, nameAttr);
  }
  activate(Instruction instruction) {
    return this._compiler.compileInHost(instruction.component).then((pv) {
      var outletInjector = this._injector.resolveAndCreateChild([
        bind(RouteParams).toValue(new RouteParams(instruction.params)),
        bind(routerMod.Router).toValue(instruction.router)
      ]);
      this._viewContainer.clear();
      this._viewContainer.create(pv, 0, null, outletInjector);
    });
  }
  canActivate(dynamic instruction) {
    return PromiseWrapper.resolve(true);
  }
  canDeactivate(dynamic instruction) {
    return PromiseWrapper.resolve(true);
  }
}
