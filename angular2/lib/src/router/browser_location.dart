library angular2.src.router.browser_location;

import "package:angular2/src/dom/dom_adapter.dart" show DOM;

class BrowserLocation {
  var _location;
  var _history;
  String _baseHref;
  BrowserLocation() {
    this._location = DOM.getLocation();
    this._history = DOM.getHistory();
    this._baseHref = DOM.getBaseHref();
  }
  onPopState(fn) {
    DOM.getGlobalEventTarget("window").addEventListener("popstate", fn, false);
  }
  getBaseHref() {
    return this._baseHref;
  }
  path() {
    return this._location.pathname;
  }
  pushState(dynamic state, String title, String url) {
    this._history.pushState(state, title, url);
  }
  forward() {
    this._history.forward();
  }
  back() {
    this._history.back();
  }
}
