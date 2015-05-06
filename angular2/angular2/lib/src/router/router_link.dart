library angular2.src.router.router_link;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/core.dart" show ElementRef;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "router.dart"
    show
        Router; /**
 * The RouterLink directive lets you link to specific parts of your app.
 *
 *
 * Consider the following route configuration:

 * ```
 * @RouteConfig({
 *   path: '/user', component: UserCmp, alias: 'user'
 * });
 * class MyComp {}
 * ```
 *
 * When linking to a route, you can write:
 *
 * ```
 * <a router-link="user">link to user component</a>
 * ```
 *
 * @exportedAs angular2/router
 */

@Directive(
    selector: "[router-link]",
    properties: const {"route": "routerLink", "params": "routerParams"})
class RouterLink {
  var _domEl;
  String _route;
  dynamic _params;
  Router _router; //TODO: handle click events
  RouterLink(ElementRef elementRef, Router router) {
    this._domEl = elementRef.domElement;
    this._router = router;
  }
  set route(changes) {
    this._route = changes;
    this.updateHref();
  }
  set params(changes) {
    this._params = changes;
    this.updateHref();
  }
  updateHref() {
    if (isPresent(this._route) && isPresent(this._params)) {
      var newHref = this._router.generate(this._route, this._params);
      DOM.setAttribute(this._domEl, "href", newHref);
    }
  }
}
