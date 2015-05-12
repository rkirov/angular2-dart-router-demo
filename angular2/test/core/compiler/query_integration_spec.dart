library angular2.test.core.compiler.query_integration_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        describe,
        el,
        expect,
        iit,
        inject,
        IS_NODEJS,
        it,
        xit;
import "package:angular2/src/test_lib/test_bed.dart" show TestBed;
import "package:angular2/src/core/compiler/query_list.dart" show QueryList;
import "package:angular2/src/core/annotations_impl/di.dart" show Query;
import "package:angular2/angular2.dart" show If, For;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;

main() {
  BrowserDomAdapter.makeCurrent();
  describe("Query API", () {
    it("should contain all directives in the light dom", inject([
      TestBed,
      AsyncTestCompleter
    ], (tb, async) {
      var template = "<div text=\"1\"></div>" +
          "<needs-query text=\"2\"><div text=\"3\"></div></needs-query>" +
          "<div text=\"4\"></div>";
      tb.createView(MyComp, html: template).then((view) {
        view.detectChanges();
        expect(view.rootNodes).toHaveText("2|3|");
        async.done();
      });
    }));
    it("should reflect dynamically inserted directives", inject([
      TestBed,
      AsyncTestCompleter
    ], (tb, async) {
      var template = "<div text=\"1\"></div>" +
          "<needs-query text=\"2\"><div *if=\"shouldShow\" [text]=\"'3'\"></div></needs-query>" +
          "<div text=\"4\"></div>";
      tb.createView(MyComp, html: template).then((view) {
        view.detectChanges();
        expect(view.rootNodes).toHaveText("2|");
        view.context.shouldShow = true;
        view.detectChanges();
        // TODO(rado): figure out why the second tick is necessary.
        view.detectChanges();
        expect(view.rootNodes).toHaveText("2|3|");
        async.done();
      });
    }));
    it("should reflect moved directives", inject([
      TestBed,
      AsyncTestCompleter
    ], (tb, async) {
      var template = "<div text=\"1\"></div>" +
          "<needs-query text=\"2\"><div *for=\"var i of list\" [text]=\"i\"></div></needs-query>" +
          "<div text=\"4\"></div>";
      tb.createView(MyComp, html: template).then((view) {
        view.detectChanges();
        view.detectChanges();
        expect(view.rootNodes).toHaveText("2|1d|2d|3d|");
        view.context.list = ["3d", "2d"];
        view.detectChanges();
        view.detectChanges();
        expect(view.rootNodes).toHaveText("2|3d|2d|");
        async.done();
      });
    }));
  });
}
@Component(selector: "needs-query")
@View(
    directives: const [For],
    template: "<div *for=\"var dir of query\">{{dir.text}}|</div>")
class NeedsQuery {
  QueryList query;
  NeedsQuery(@Query(TextDirective) QueryList query) {
    this.query = query;
  }
}
var _constructiontext = 0;
@Directive(selector: "[text]", properties: const {"text": "text"})
class TextDirective {
  String text;
  TextDirective() {}
}
@Component(selector: "my-comp")
@View(directives: const [NeedsQuery, TextDirective, If, For])
class MyComp {
  bool shouldShow;
  var list;
  MyComp() {
    this.shouldShow = false;
    this.list = ["1d", "2d", "3d"];
  }
}
