library angular2.test.services.xhr_impl_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        describe,
        expect,
        iit,
        inject,
        it,
        xit;
import "package:angular2/src/services/xhr_impl.dart" show XHRImpl;
import "package:angular2/src/facade/async.dart" show PromiseWrapper;

main() {
  describe("XHRImpl", () {
    var xhr;
    var url200 = "/base/modules/angular2/test/services/static_assets/200.html";
    var url404 = "/base/modules/angular2/test/services/static_assets/404.html";
    beforeEach(() {
      xhr = new XHRImpl();
    });
    it("should resolve the Promise with the file content on success", inject(
        [AsyncTestCompleter], (async) {
      xhr.get(url200).then((text) {
        expect(text.trim()).toEqual("<p>hey</p>");
        async.done();
      });
    }));
    it("should reject the Promise on failure", inject([AsyncTestCompleter],
        (async) {
      PromiseWrapper.catchError(xhr.get(url404), (e) {
        expect(e).toEqual('''Failed to load ${ url404}''');
        async.done();
      });
    }));
  });
}
