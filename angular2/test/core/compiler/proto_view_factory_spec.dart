library angular2.test.core.compiler.proto_view_factory_spec;

import "package:angular2/test_lib.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        xdescribe,
        ddescribe,
        describe,
        el,
        expect,
        iit,
        inject,
        IS_DARTIUM,
        it,
        SpyObject,
        proxy;
import "package:angular2/src/facade/lang.dart" show isBlank;
import "package:angular2/src/facade/collection.dart" show MapWrapper;
import "package:angular2/change_detection.dart"
    show ChangeDetection, ChangeDetectorDefinition;
import "package:angular2/src/core/compiler/proto_view_factory.dart"
    show ProtoViewFactory, getChangeDetectorDefinitions;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/compiler/directive_resolver.dart"
    show DirectiveResolver;
import "package:angular2/src/core/compiler/element_injector.dart"
    show DirectiveBinding;
import "package:angular2/src/render/api.dart" as renderApi;

main() {
  // TODO(tbosch): add missing tests
  describe("ProtoViewFactory", () {
    var changeDetection;
    var protoViewFactory;
    var directiveResolver;
    beforeEach(() {
      directiveResolver = new DirectiveResolver();
      changeDetection = new ChangeDetectionSpy();
      protoViewFactory = new ProtoViewFactory(changeDetection);
    });
    bindDirective(type) {
      return DirectiveBinding.createFromType(
          type, directiveResolver.resolve(type));
    }
    describe("getChangeDetectorDefinitions", () {
      it("should create a ChangeDetectorDefinition for the root render proto view",
          () {
        var renderPv = createRenderProtoView();
        var defs = getChangeDetectorDefinitions(
            bindDirective(MainComponent).metadata, renderPv, []);
        expect(defs.length).toBe(1);
        expect(defs[0].id).toEqual("MainComponent_comp_0");
      });
    });
    describe("createAppProtoViews", () {
      it("should create an AppProtoView for the root render proto view", () {
        var renderPv = createRenderProtoView();
        var pvs = protoViewFactory.createAppProtoViews(
            bindDirective(MainComponent), renderPv, []);
        expect(pvs.length).toBe(1);
        expect(pvs[0].render).toBe(renderPv.render);
      });
    });
  });
}
createRenderProtoView([elementBinders = null, num type = null]) {
  if (isBlank(type)) {
    type = renderApi.ProtoViewDto.COMPONENT_VIEW_TYPE;
  }
  if (isBlank(elementBinders)) {
    elementBinders = [];
  }
  return new renderApi.ProtoViewDto(
      elementBinders: elementBinders,
      type: type,
      variableBindings: MapWrapper.create());
}
createRenderComponentElementBinder(directiveIndex) {
  return new renderApi.ElementBinder(
      directives: [
    new renderApi.DirectiveBinder(directiveIndex: directiveIndex)
  ]);
}
createRenderViewportElementBinder(nestedProtoView) {
  return new renderApi.ElementBinder(nestedProtoView: nestedProtoView);
}
@proxy
class ChangeDetectionSpy extends SpyObject implements ChangeDetection {
  ChangeDetectionSpy() : super(ChangeDetection) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
@Component(selector: "main-comp")
class MainComponent {}
