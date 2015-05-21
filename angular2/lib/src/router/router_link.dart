library angular2.src.router.router_link;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive, onAllChangesDone;
import "package:angular2/core.dart" show ElementRef;
import "package:angular2/src/facade/collection.dart" show Map, StringMapWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "router.dart" show Router;
import "location.dart" show Location;

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
  Map<String, String> _params;
  Router _router;
  Location _location;
  // the url displayed on the anchor element.
  String _visibleHref;
  // the url passed to the router navigation.
  String _navigationHref;
  RouterLink(ElementRef elementRef, Router router, Location location) {
    this._domEl = elementRef.domElement;
    this._router = router;
    this._location = location;
    this._params = StringMapWrapper.create();
    DOM.on(this._domEl, "click", (evt) {
      evt.preventDefault();
      this._router.navigate(this._navigationHref);
    });
  }
  set route(String changes) {
    this._route = changes;
  }
  set params(Map changes) {
    this._params = changes;
  }
  void onAllChangesDone() {
    if (isPresent(this._route) && isPresent(this._params)) {
      this._navigationHref = this._router.generate(this._route, this._params);
      this._visibleHref =
          this._location.normalizeAbsolutely(this._navigationHref);
      // Keeping the link on the element to support contextual menu `copy link`

      // and other in-browser affordances.
      DOM.setAttribute(this._domEl, "href", this._visibleHref);
    }
  }
}
