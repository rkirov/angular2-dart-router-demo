library angular2.test.router.location_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        describe,
        proxy,
        it,
        iit,
        ddescribe,
        expect,
        inject,
        beforeEach,
        beforeEachBindings,
        SpyObject;
import "package:angular2/src/facade/async.dart"
    show EventEmitter, ObservableWrapper;
import "package:angular2/src/router/browser_location.dart" show BrowserLocation;
import "package:angular2/src/router/location.dart" show Location;

main() {
  describe("Location", () {
    var browserLocation, location;
    beforeEach(() {
      browserLocation = new DummyBrowserLocation();
      browserLocation.spy("pushState");
      browserLocation.baseHref = "/my/app";
      location = new Location(browserLocation);
    });
    it("should normalize relative urls on navigate", () {
      location.go("user/btford");
      expect(browserLocation.spy("pushState")).toHaveBeenCalledWith(
          null, "", "/my/app/user/btford");
    });
    it("should not append urls with leading slash on navigate", () {
      location.go("/my/app/user/btford");
      expect(browserLocation.spy("pushState")).toHaveBeenCalledWith(
          null, "", "/my/app/user/btford");
    });
    it("should remove index.html from base href", () {
      browserLocation.baseHref = "/my/app/index.html";
      location = new Location(browserLocation);
      location.go("user/btford");
      expect(browserLocation.spy("pushState")).toHaveBeenCalledWith(
          null, "", "/my/app/user/btford");
    });
    it("should normalize urls on popstate", inject([AsyncTestCompleter],
        (async) {
      browserLocation.simulatePopState("/my/app/user/btford");
      location.subscribe((ev) {
        expect(ev["url"]).toEqual("/user/btford");
        async.done();
      });
    }));
    it("should normalize location path", () {
      browserLocation.internalPath = "/my/app/user/btford";
      expect(location.path()).toEqual("/user/btford");
    });
  });
}
@proxy
class DummyBrowserLocation extends SpyObject implements BrowserLocation {
  var baseHref;
  var internalPath;
  EventEmitter _subject;
  DummyBrowserLocation() : super() {
    /* super call moved to initializer */;
    this.internalPath = "/";
    this._subject = new EventEmitter();
  }
  simulatePopState(url) {
    this.internalPath = url;
    ObservableWrapper.callNext(this._subject, null);
  }
  path() {
    return this.internalPath;
  }
  onPopState(fn) {
    ObservableWrapper.subscribe(this._subject, fn);
  }
  getBaseHref() {
    return this.baseHref;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
