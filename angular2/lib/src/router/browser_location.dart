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
  void onPopState(Function fn) {
    DOM.getGlobalEventTarget("window").addEventListener("popstate", fn, false);
  }
  String getBaseHref() {
    return this._baseHref;
  }
  String path() {
    return this._location.pathname;
  }
  pushState(dynamic state, String title, String url) {
    this._history.pushState(state, title, url);
  }
  void forward() {
    this._history.forward();
  }
  void back() {
    this._history.back();
  }
}
