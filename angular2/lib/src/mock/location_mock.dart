library angular2.src.mock.location_mock;

import "package:angular2/test_lib.dart" show SpyObject, proxy;
import "package:angular2/src/facade/async.dart"
    show EventEmitter, ObservableWrapper;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/router/location.dart" show Location;

@proxy
class SpyLocation extends SpyObject implements Location {
  List<String> urlChanges;
  String _path;
  EventEmitter _subject;
  String _baseHref;
  SpyLocation() : super() {
    /* super call moved to initializer */;
    this._path = "/";
    this.urlChanges = ListWrapper.create();
    this._subject = new EventEmitter();
    this._baseHref = "";
  }
  setInitialPath(String url) {
    this._path = url;
  }
  setBaseHref(String url) {
    this._baseHref = url;
  }
  String path() {
    return this._path;
  }
  simulateUrlPop(String pathname) {
    ObservableWrapper.callNext(this._subject, {"url": pathname});
  }
  normalizeAbsolutely(url) {
    return this._baseHref + url;
  }
  go(String url) {
    url = this.normalizeAbsolutely(url);
    if (this._path == url) {
      return;
    }
    this._path = url;
    ListWrapper.push(this.urlChanges, url);
  }
  forward() {}
  back() {}
  subscribe(onNext, [onThrow = null, onReturn = null]) {
    ObservableWrapper.subscribe(this._subject, onNext, onThrow, onReturn);
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
