library angular2.test.render.dom.compiler.compiler_common_tests;

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
        IS_DARTIUM,
        it;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map, MapWrapper, StringMapWrapper;
import "package:angular2/src/facade/lang.dart"
    show Type, isBlank, stringify, isPresent;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "package:angular2/src/render/dom/compiler/compiler.dart"
    show DomCompiler;
import "package:angular2/src/render/api.dart"
    show ProtoViewDto, ViewDefinition, DirectiveMetadata;
import "package:angular2/src/render/dom/compiler/compile_element.dart"
    show CompileElement;
import "package:angular2/src/render/dom/compiler/compile_step.dart"
    show CompileStep;
import "package:angular2/src/render/dom/compiler/compile_step_factory.dart"
    show CompileStepFactory;
import "package:angular2/src/render/dom/compiler/compile_control.dart"
    show CompileControl;
import "package:angular2/src/render/dom/compiler/template_loader.dart"
    show TemplateLoader;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/render/dom/view/proto_view.dart"
    show resolveInternalDomProtoView;

runCompilerCommonTests() {
  describe("DomCompiler", () {
    var mockStepFactory;
    createCompiler(processClosure, [urlData = null]) {
      if (isBlank(urlData)) {
        urlData = MapWrapper.create();
      }
      var tplLoader = new FakeTemplateLoader(urlData);
      mockStepFactory = new MockStepFactory([new MockStep(processClosure)]);
      return new DomCompiler(mockStepFactory, tplLoader);
    }
    describe("compile", () {
      it("should run the steps and build the AppProtoView of the root element",
          inject([AsyncTestCompleter], (async) {
        var compiler = createCompiler((parent, current, control) {
          current.inheritedProtoView.bindVariable("b", "a");
        });
        compiler
            .compile(new ViewDefinition(
                componentId: "someComponent", template: "<div></div>"))
            .then((protoView) {
          expect(protoView.variableBindings)
              .toEqual(MapWrapper.createFromStringMap({"a": "b"}));
          async.done();
        });
      }));
      it("should run the steps and build the proto view", inject(
          [AsyncTestCompleter], (async) {
        var compiler = createCompiler((parent, current, control) {
          current.inheritedProtoView.bindVariable("b", "a");
        });
        var dirMetadata = new DirectiveMetadata(
            id: "id",
            selector: "CUSTOM",
            type: DirectiveMetadata.COMPONENT_TYPE);
        compiler.compileHost(dirMetadata).then((protoView) {
          expect(DOM.tagName(
                  resolveInternalDomProtoView(protoView.render).element))
              .toEqual("CUSTOM");
          expect(mockStepFactory.viewDef.directives).toEqual([dirMetadata]);
          expect(protoView.variableBindings)
              .toEqual(MapWrapper.createFromStringMap({"a": "b"}));
          async.done();
        });
      }));
      it("should use the inline template and compile in sync", inject(
          [AsyncTestCompleter], (async) {
        var compiler = createCompiler(EMPTY_STEP);
        compiler
            .compile(new ViewDefinition(
                componentId: "someId", template: "inline component"))
            .then((protoView) {
          expect(DOM.getInnerHTML(
                  resolveInternalDomProtoView(protoView.render).element))
              .toEqual("inline component");
          async.done();
        });
      }));
      it("should load url templates", inject([AsyncTestCompleter], (async) {
        var urlData =
            MapWrapper.createFromStringMap({"someUrl": "url component"});
        var compiler = createCompiler(EMPTY_STEP, urlData);
        compiler
            .compile(
                new ViewDefinition(componentId: "someId", absUrl: "someUrl"))
            .then((protoView) {
          expect(DOM.getInnerHTML(
                  resolveInternalDomProtoView(protoView.render).element))
              .toEqual("url component");
          async.done();
        });
      }));
      it("should report loading errors", inject([AsyncTestCompleter], (async) {
        var compiler = createCompiler(EMPTY_STEP, MapWrapper.create());
        PromiseWrapper.catchError(compiler.compile(
            new ViewDefinition(componentId: "someId", absUrl: "someUrl")), (e) {
          expect(e.message)
              .toContain('''Failed to load the template "someId"''');
          async.done();
        });
      }));
      it("should wait for async subtasks to be resolved", inject(
          [AsyncTestCompleter], (async) {
        var subTasksCompleted = false;
        var completer = PromiseWrapper.completer();
        var compiler = createCompiler((parent, current, control) {
          ListWrapper.push(mockStepFactory.subTaskPromises, completer.promise
              .then((_) {
            subTasksCompleted = true;
          }));
        });
        // It should always return a Promise because the subtask is async
        var pvPromise = compiler.compile(new ViewDefinition(
            componentId: "someId", template: "some component"));
        expect(pvPromise).toBePromise();
        expect(subTasksCompleted).toEqual(false);
        // The Promise should resolve after the subtask is ready
        completer.resolve(null);
        pvPromise.then((protoView) {
          expect(subTasksCompleted).toEqual(true);
          async.done();
        });
      }));
      it("should return ProtoViews of type COMPONENT_VIEW_TYPE", inject(
          [AsyncTestCompleter], (async) {
        var compiler = createCompiler(EMPTY_STEP);
        compiler
            .compile(new ViewDefinition(
                componentId: "someId", template: "inline component"))
            .then((protoView) {
          expect(protoView.type).toEqual(ProtoViewDto.COMPONENT_VIEW_TYPE);
          async.done();
        });
      }));
    });
    describe("compileHost", () {
      it("should return ProtoViews of type HOST_VIEW_TYPE", inject(
          [AsyncTestCompleter], (async) {
        var compiler = createCompiler(EMPTY_STEP);
        compiler.compileHost(someComponent).then((protoView) {
          expect(protoView.type).toEqual(ProtoViewDto.HOST_VIEW_TYPE);
          async.done();
        });
      }));
    });
  });
}
class MockStepFactory extends CompileStepFactory {
  List<CompileStep> steps;
  List<Future> subTaskPromises;
  ViewDefinition viewDef;
  MockStepFactory(steps) : super() {
    /* super call moved to initializer */;
    this.steps = steps;
  }
  createSteps(viewDef, subTaskPromises) {
    this.viewDef = viewDef;
    this.subTaskPromises = subTaskPromises;
    ListWrapper.forEach(
        this.subTaskPromises, (p) => ListWrapper.push(subTaskPromises, p));
    return this.steps;
  }
}
class MockStep {
  Function processClosure;
  MockStep(process) {
    this.processClosure = process;
  }
  process(
      CompileElement parent, CompileElement current, CompileControl control) {
    this.processClosure(parent, current, control);
  }
}
var EMPTY_STEP = (parent, current, control) {
  if (isPresent(parent)) {
    current.inheritedProtoView = parent.inheritedProtoView;
  }
};
class FakeTemplateLoader extends TemplateLoader {
  Map<String, String> _urlData;
  FakeTemplateLoader(urlData) : super(null, new UrlResolver()) {
    /* super call moved to initializer */;
    this._urlData = urlData;
  }
  load(ViewDefinition template) {
    if (isPresent(template.template)) {
      return PromiseWrapper.resolve(DOM.createTemplate(template.template));
    }
    if (isPresent(template.absUrl)) {
      var content = MapWrapper.get(this._urlData, template.absUrl);
      if (isPresent(content)) {
        return PromiseWrapper.resolve(DOM.createTemplate(content));
      }
    }
    return PromiseWrapper.reject("Load failed", null);
  }
}
var someComponent = new DirectiveMetadata(
    selector: "some-comp",
    id: "someComponent",
    type: DirectiveMetadata.COMPONENT_TYPE);
