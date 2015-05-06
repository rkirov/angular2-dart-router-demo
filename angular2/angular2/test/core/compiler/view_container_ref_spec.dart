library angular2.test.core.compiler.view_container_ref_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        ddescribe,
        xdescribe,
        describe,
        el,
        dispatchEvent,
        expect,
        iit,
        inject,
        beforeEachBindings,
        it,
        xit,
        SpyObject,
        proxy;
import "package:angular2/src/facade/collection.dart" show MapWrapper;
import "package:angular2/src/facade/lang.dart"
    show IMPLEMENTS, isBlank, isPresent;
import "package:angular2/src/core/compiler/view.dart"
    show AppView, AppProtoView, AppViewContainer;
import "package:angular2/src/core/compiler/view_ref.dart"
    show ProtoViewRef, ViewRef, internalView;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;
import "package:angular2/src/core/compiler/view_container_ref.dart"
    show ViewContainerRef;
import "package:angular2/src/core/compiler/view_manager.dart"
    show AppViewManager;

main() {
  // TODO(tbosch): add missing tests
  describe("ViewContainerRef", () {
    var location;
    var view;
    var viewManager;
    ViewRef wrapView(AppView view) {
      return new ViewRef(view);
    }
    createProtoView() {
      return new AppProtoView(null, null, null, null, null);
    }
    createView() {
      return new AppView(null, createProtoView(), MapWrapper.create());
    }
    createViewContainer() {
      return new ViewContainerRef(viewManager, location);
    }
    beforeEach(() {
      viewManager = new AppViewManagerSpy();
      view = createView();
      view.viewContainers = [null];
      location = new ElementRef(wrapView(view), 0);
    });
    it("should return a 0 length if there is no underlying ViewContainerRef",
        () {
      var vc = createViewContainer();
      expect(vc.length).toBe(0);
    });
    it("should return the size of the underlying ViewContainerRef", () {
      var vc = createViewContainer();
      view.viewContainers = [new AppViewContainer()];
      view.viewContainers[0].views = [createView()];
      expect(vc.length).toBe(1);
    });
  });
}
@proxy
@IMPLEMENTS(AppViewManager)
class AppViewManagerSpy extends SpyObject implements AppViewManager {
  AppViewManagerSpy() : super(AppViewManager) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
