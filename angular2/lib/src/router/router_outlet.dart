library angular2.src.router.router_outlet;

import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/lang.dart" show isBlank, isPresent;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/src/core/annotations_impl/di.dart" show Attribute;
import "package:angular2/core.dart"
    show DynamicComponentLoader, ComponentRef, ElementRef;
import "package:angular2/di.dart" show Injector, bind;
import "router.dart" as routerMod;
import "instruction.dart" show Instruction, RouteParams;

/**
 * A router outlet is a placeholder that Angular dynamically fills based on the application's route.
 *
 * ## Use
 *
 * ```
 * <router-outlet></router-outlet>
 * ```
 *
 * Route outlets can also optionally have a name:
 *
 * ```
 * <router-outlet name="side"></router-outlet>
 * <router-outlet name="main"></router-outlet>
 * ```
 *
 */
@Directive(selector: "router-outlet")
class RouterOutlet {
  Injector _injector;
  routerMod.Router _parentRouter;
  routerMod.Router _childRouter;
  DynamicComponentLoader _loader;
  ComponentRef _componentRef;
  ElementRef _elementRef;
  Instruction _currentInstruction;
  RouterOutlet(ElementRef elementRef, DynamicComponentLoader loader,
      routerMod.Router router, Injector injector,
      @Attribute("name") String nameAttr) {
    if (isBlank(nameAttr)) {
      nameAttr = "default";
    }
    this._loader = loader;
    this._parentRouter = router;
    this._elementRef = elementRef;
    this._injector = injector;
    this._childRouter = null;
    this._componentRef = null;
    this._currentInstruction = null;
    this._parentRouter.registerOutlet(this, nameAttr);
  }
  /**
   * Given an instruction, update the contents of this viewport.
   */
  Future activate(Instruction instruction) {
    // if we're able to reuse the component, we just have to pass along the instruction to the component's router

    // so it can propagate changes to its children
    if ((instruction == this._currentInstruction) ||
        instruction.reuse && isPresent(this._childRouter)) {
      return this._childRouter.commit(instruction);
    }
    this._currentInstruction = instruction;
    this._childRouter = this._parentRouter.childRouter(instruction.component);
    var outletInjector = this._injector.resolveAndCreateChild([
      bind(RouteParams).toValue(new RouteParams(instruction.params)),
      bind(routerMod.Router).toValue(this._childRouter)
    ]);
    if (isPresent(this._componentRef)) {
      this._componentRef.dispose();
    }
    return this._loader
        .loadNextToExistingLocation(
            instruction.component, this._elementRef, outletInjector)
        .then((componentRef) {
      this._componentRef = componentRef;
      return this._childRouter.commit(instruction);
    });
  }
  Future deactivate() {
    return (isPresent(this._childRouter)
            ? this._childRouter.deactivate()
            : PromiseWrapper.resolve(true))
        .then((_) => this._componentRef.dispose());
  }
  Future<bool> canDeactivate(Instruction instruction) {
    // TODO: how to get ahold of the component instance here?
    return PromiseWrapper.resolve(true);
  }
}
