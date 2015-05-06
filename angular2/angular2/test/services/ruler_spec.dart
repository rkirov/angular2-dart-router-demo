library angular2.test.services.ruler_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        inject,
        ddescribe,
        describe,
        it,
        iit,
        xit,
        expect,
        SpyObject,
        proxy;
import "package:angular2/src/dom/dom_adapter.dart" show DOM, DomAdapter;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;
import "package:angular2/src/services/ruler.dart" show Ruler, Rectangle;
import "rectangle_mock.dart" show createRectangle;
import "package:angular2/src/facade/lang.dart" show IMPLEMENTS;

assertDimensions(Rectangle rect, left, right, top, bottom, width, height) {
  expect(rect.left).toEqual(left);
  expect(rect.right).toEqual(right);
  expect(rect.top).toEqual(top);
  expect(rect.bottom).toEqual(bottom);
  expect(rect.width).toEqual(width);
  expect(rect.height).toEqual(height);
}
main() {
  describe("ruler service", () {
    it("should allow measuring ElementRefs", inject([AsyncTestCompleter],
        (async) {
      var ruler = new Ruler(SpyObject.stub(new SpyDomAdapter(), {
        "getBoundingClientRect": createRectangle(10, 20, 200, 100)
      }));
      var elRef = new SpyElementRef();
      ruler.measure(elRef).then((rect) {
        assertDimensions(rect, 10, 210, 20, 120, 200, 100);
        async.done();
      });
    }));
    it("should return 0 for all rectangle values while measuring elements in a document fragment",
        inject([AsyncTestCompleter], (async) {
      var ruler = new Ruler(DOM);
      var elRef = new SpyElementRef();
      elRef.domElement = DOM.createElement("div");
      ruler.measure(elRef).then((rect) {
        //here we are using an element created in a doc fragment so all the measures will come back as 0
        assertDimensions(rect, 0, 0, 0, 0, 0, 0);
        async.done();
      });
    }));
  });
}
@proxy
@IMPLEMENTS(ElementRef)
class SpyElementRef extends SpyObject implements ElementRef {
  var domElement;
  SpyElementRef() : super(ElementRef) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@proxy
@IMPLEMENTS(DomAdapter)
class SpyDomAdapter extends SpyObject implements DomAdapter {
  SpyDomAdapter() : super(DomAdapter) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
