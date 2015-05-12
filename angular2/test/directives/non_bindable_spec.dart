library angular2.test.directives.non_bindable_spec;

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
        it,
        xit;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive, Component;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;
import "package:angular2/src/directives/non_bindable.dart" show NonBindable;
import "package:angular2/src/test_lib/test_bed.dart" show TestBed;

main() {
  describe("non-bindable", () {
    it("should not interpolate children", inject([
      TestBed,
      AsyncTestCompleter
    ], (tb, async) {
      var template = "<div>{{text}}<span non-bindable>{{text}}</span></div>";
      tb.createView(TestComponent, html: template).then((view) {
        view.detectChanges();
        expect(DOM.getText(view.rootNodes[0])).toEqual("foo{{text}}");
        async.done();
      });
    }));
    it("should ignore directives on child nodes", inject([
      TestBed,
      AsyncTestCompleter
    ], (tb, async) {
      var template =
          "<div non-bindable><span id=child test-dec>{{text}}</span></div>";
      tb.createView(TestComponent, html: template).then((view) {
        view.detectChanges();
        var span = DOM.querySelector(view.rootNodes[0], "#child");
        expect(DOM.hasClass(span, "compiled")).toBeFalsy();
        async.done();
      });
    }));
    it("should trigger directives on the same node", inject([
      TestBed,
      AsyncTestCompleter
    ], (tb, async) {
      var template =
          "<div><span id=child non-bindable test-dec>{{text}}</span></div>";
      tb.createView(TestComponent, html: template).then((view) {
        view.detectChanges();
        var span = DOM.querySelector(view.rootNodes[0], "#child");
        expect(DOM.hasClass(span, "compiled")).toBeTruthy();
        async.done();
      });
    }));
  });
}
@Component(selector: "test-cmp")
@View(directives: const [NonBindable, TestDirective])
class TestComponent {
  String text;
  TestComponent() {
    this.text = "foo";
  }
}
@Directive(selector: "[test-dec]")
class TestDirective {
  TestDirective(ElementRef el) {
    DOM.addClass(el.domElement, "compiled");
  }
}
