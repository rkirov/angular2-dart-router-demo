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
  void _onPopState(_) {
    ObservableWrapper.callNext(this._subject, {"url": this.path()});
  }
  String path() {
    return this.normalize(this._browserLocation.path());
  }
  String normalize(String url) {
    return this._stripBaseHref(stripIndexHtml(url));
  }
  String normalizeAbsolutely(String url) {
    if (url[0] != "/") {
      url = "/" + url;
    }
    return this._addBaseHref(url);
  }
  String _stripBaseHref(String url) {
    if (this._baseHref.length > 0 &&
        StringWrapper.startsWith(url, this._baseHref)) {
      return StringWrapper.substring(url, this._baseHref.length);
    }
    return url;
  }
  String _addBaseHref(String url) {
    if (!StringWrapper.startsWith(url, this._baseHref)) {
      return this._baseHref + url;
    }
    return url;
  }
  void go(String url) {
    var finalUrl = this.normalizeAbsolutely(url);
    this._browserLocation.pushState(null, "", finalUrl);
  }
  void forward() {
    this._browserLocation.forward();
  }
  void back() {
    this._browserLocation.back();
  }
  void subscribe(onNext, [onThrow = null, onReturn = null]) {
    ObservableWrapper.subscribe(this._subject, onNext, onThrow, onReturn);
  }
}
String stripIndexHtml(String url) {
  // '/index.html'.length == 11
  if (url.length > 10 &&
      StringWrapper.substring(url, url.length - 11) == "/index.html") {
    return StringWrapper.substring(url, 0, url.length - 11);
  }
  return url;
}
