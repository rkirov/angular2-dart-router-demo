library angular2.src.router.location;

import "browser_location.dart" show BrowserLocation;
import "package:angular2/src/facade/lang.dart" show StringWrapper;
import "package:angular2/src/facade/async.dart"
    show EventEmitter, ObservableWrapper;

class Location {
  EventEmitter _subject;
  BrowserLocation _browserLocation;
  String _baseHref;
  Location(BrowserLocation browserLocation) {
    this._subject = new EventEmitter();
    this._browserLocation = browserLocation;
    this._baseHref = stripIndexHtml(this._browserLocation.getBaseHref());
    this._browserLocation.onPopState((_) => this._onPopState(_));
  }
  _onPopState(_) {
    ObservableWrapper.callNext(this._subject, {"url": this.path()});
  }
  path() {
    return this.normalize(this._browserLocation.path());
  }
  normalize(url) {
    return this._stripBaseHref(stripIndexHtml(url));
  }
  _stripBaseHref(url) {
    if (this._baseHref.length > 0 &&
        StringWrapper.startsWith(url, this._baseHref)) {
      return StringWrapper.substring(url, this._baseHref.length);
    }
    return url;
  }
  go(String url) {
    var finalUrl = url[0] == "/" ? url : this._baseHref + "/" + url;
    this._browserLocation.pushState(null, "", finalUrl);
  }
  forward() {
    this._browserLocation.forward();
  }
  back() {
    this._browserLocation.back();
  }
  subscribe(onNext, [onThrow = null, onReturn = null]) {
    ObservableWrapper.subscribe(this._subject, onNext, onThrow, onReturn);
  }
}
stripIndexHtml(url) {
  // '/index.html'.length == 11
  if (url.length > 10 &&
      StringWrapper.substring(url, url.length - 11) == "/index.html") {
    return StringWrapper.substring(url, 0, url.length - 11);
  }
  return url;
}
