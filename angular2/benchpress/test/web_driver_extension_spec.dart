library benchpress.test.web_driver_extension_spec;

import "package:angular2/test_lib.dart"
    show
        afterEach,
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        describe,
        expect,
        iit,
        inject,
        it,
        xit;
import "package:angular2/src/facade/collection.dart" show Map, ListWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent, StringWrapper;
import "package:angular2/src/facade/async.dart" show PromiseWrapper;
import "package:benchpress/common.dart"
    show WebDriverExtension, bind, Injector, Options;

main() {
  createExtension(ids, caps) {
    return Injector
        .resolveAndCreate([
      ListWrapper.map(ids, (id) => bind(id).toValue(new MockExtension(id))),
      bind(Options.CAPABILITIES).toValue(caps),
      WebDriverExtension.bindTo(ids)
    ])
        .asyncGet(WebDriverExtension);
  }
  describe("WebDriverExtension.bindTo", () {
    it("should bind the extension that matches the capabilities", inject(
        [AsyncTestCompleter], (async) {
      createExtension(["m1", "m2", "m3"], {"browser": "m2"}).then((m) {
        expect(m.id).toEqual("m2");
        async.done();
      });
    }));
    it("should throw if there is no match", inject([AsyncTestCompleter],
        (async) {
      PromiseWrapper.catchError(createExtension(["m1"], {"browser": "m2"}),
          (err) {
        expect(isPresent(err)).toBe(true);
        async.done();
      });
    }));
  });
}
class MockExtension extends WebDriverExtension {
  String id;
  MockExtension(id) : super() {
    /* super call moved to initializer */;
    this.id = id;
  }
  bool supports(Map capabilities) {
    return StringWrapper.equals(capabilities["browser"], this.id);
  }
}
