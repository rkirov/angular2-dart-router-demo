library angular2.src.router.location;

import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/async.dart"
    show EventEmitter, ObservableWrapper;

class Location {
  var _location;
  EventEmitter _subject;
  var _history;
  Location() {
    this._subject = new EventEmitter();
    this._location = DOM.getLocation();
    this._history = DOM.getHistory();
    DOM.getGlobalEventTarget("window").addEventListener(
        "popstate", (_) => this._onPopState(_), false);
  }
  _onPopState(_) {
    ObservableWrapper.callNext(this._subject, {"url": this._location.pathname});
  }
  path() {
    return this._location.pathname;
  }
  go(String url) {
    this._history.pushState(null, null, url);
  }
  forward() {
    this._history.forward();
  }
  back() {
    this._history.back();
  }
  subscribe(onNext, [onThrow = null, onReturn = null]) {
    ObservableWrapper.subscribe(this._subject, onNext, onThrow, onReturn);
  }
}
