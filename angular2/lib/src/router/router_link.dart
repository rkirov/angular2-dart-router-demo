library angular2.src.router.router_link;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive, onAllChangesDone;
import "package:angular2/core.dart" show ElementRef;
import "package:angular2/src/facade/collection.dart" show Map, StringMapWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "router.dart" show Router;

/**
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
    properties: const {"route": "routerLink", "params": "routerParams"},
    lifecycle: const [onAllChangesDone])
class RouterLink {
  var _domEl;
  String _route;
  dynamic _params;
  Router _router;
  String _href;
  RouterLink(ElementRef elementRef, Router router) {
    this._domEl = elementRef.domElement;
    this._router = router;
    this._params = StringMapWrapper.create();
    DOM.on(this._domEl, "click", (evt) {
      evt.preventDefault();
      this._router.navigate(this._href);
    });
  }
  set route(changes) {
    this._route = changes;
  }
  set params(changes) {
    this._params = changes;
  }
  onAllChangesDone() {
    if (isPresent(this._route) && isPresent(this._params)) {
      var newHref = this._router.generate(this._route, this._params);
      this._href = newHref;
      // Keeping the link on the element to support contextual menu `copy link`

      // and other in-browser affordances.
      DOM.setAttribute(this._domEl, "href", newHref);
    }
  }
}
