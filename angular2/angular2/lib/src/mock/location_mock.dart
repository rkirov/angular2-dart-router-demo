library angular2.src.mock.location_mock;

import "package:angular2/test_lib.dart" show SpyObject, proxy;
import "package:angular2/src/facade/lang.dart"
    show isBlank, isPresent, IMPLEMENTS;
import "package:angular2/src/facade/async.dart"
    show EventEmitter, ObservableWrapper;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/router/location.dart" show Location;

@proxy
@IMPLEMENTS(Location)
class SpyLocation extends SpyObject implements Location {
  List<String> urlChanges;
  String _path;
  EventEmitter _subject;
  SpyLocation() : super() {
    /* super call moved to initializer */;
    this._path = "/";
    this.urlChanges = ListWrapper.create();
    this._subject = new EventEmitter();
  }
  setInitialPath(String url) {
    this._path = url;
  }
  String path() {
    return this._path;
  }
  simulateUrlPop(String pathname) {
    ObservableWrapper.callNext(this._subject, {"url": pathname});
  }
  go(String url) {
    if (identical(this._path, url)) {
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
