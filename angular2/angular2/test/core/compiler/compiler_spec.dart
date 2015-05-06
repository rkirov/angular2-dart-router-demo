library angular2.test.core.compiler.compiler_spec;

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
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map, MapWrapper, StringMapWrapper;
import "package:angular2/src/facade/lang.dart"
    show IMPLEMENTS, Type, isBlank, stringify, isPresent;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "package:angular2/src/core/compiler/compiler.dart"
    show Compiler, CompilerCache;
import "package:angular2/src/core/compiler/view.dart" show AppProtoView;
import "package:angular2/src/core/compiler/element_binder.dart"
    show ElementBinder;
import "package:angular2/src/core/compiler/directive_metadata_reader.dart"
    show DirectiveMetadataReader;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/di.dart" show Attribute;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/compiler/view_ref.dart"
    show internalProtoView;
import "package:angular2/src/core/compiler/element_injector.dart"
    show DirectiveBinding;
import "package:angular2/src/core/compiler/template_resolver.dart"
    show TemplateResolver;
import "package:angular2/src/core/compiler/component_url_mapper.dart"
    show ComponentUrlMapper, RuntimeComponentUrlMapper;
import "package:angular2/src/core/compiler/proto_view_factory.dart"
    show ProtoViewFactory;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/render/api.dart"
    as renderApi; // TODO(tbosch): Spys don't support named modules...
import "package:angular2/src/render/api.dart" show Renderer;

main() {
  describe("compiler", () {
    var reader,
        tplResolver,
        renderer,
        protoViewFactory,
        cmpUrlMapper,
        renderCompileRequests;
    beforeEach(() {
      reader = new DirectiveMetadataReader();
      tplResolver = new FakeTemplateResolver();
      cmpUrlMapper = new RuntimeComponentUrlMapper();
      renderer = new SpyRenderer();
    });
    createCompiler(
        List renderCompileResults, List<AppProtoView> protoViewFactoryResults) {
      var urlResolver = new FakeUrlResolver();
      renderCompileRequests = [];
      renderer.spy("compile").andCallFake((template) {
        ListWrapper.push(renderCompileRequests, template);
        return PromiseWrapper
            .resolve(ListWrapper.removeAt(renderCompileResults, 0));
      });
      protoViewFactory = new FakeProtoViewFactory(protoViewFactoryResults);
      return new Compiler(reader, new CompilerCache(), tplResolver,
          cmpUrlMapper, urlResolver, renderer, protoViewFactory);
    }
    describe("serialize template", () {
      Future<renderApi.ViewDefinition> captureTemplate(View template) {
        tplResolver.setView(MainComponent, template);
        var compiler =
            createCompiler([createRenderProtoView()], [createProtoView()]);
        return compiler.compile(MainComponent).then((_) {
          expect(renderCompileRequests.length).toBe(1);
          return renderCompileRequests[0];
        });
      }
      Future<renderApi.DirectiveMetadata> captureDirective(directive) {
        return captureTemplate(
                new View(template: "<div></div>", directives: [directive]))
            .then((renderTpl) {
          expect(renderTpl.directives.length).toBe(1);
          return renderTpl.directives[0];
        });
      }
      it("should fill the componentId", inject([AsyncTestCompleter], (async) {
        captureTemplate(new View(template: "<div></div>")).then((renderTpl) {
          expect(renderTpl.componentId).toEqual(stringify(MainComponent));
          async.done();
        });
      }));
      it("should fill inline template", inject([AsyncTestCompleter], (async) {
        captureTemplate(new View(template: "<div></div>")).then((renderTpl) {
          expect(renderTpl.template).toEqual("<div></div>");
          async.done();
        });
      }));
      it("should fill absUrl given inline templates", inject(
          [AsyncTestCompleter], (async) {
        cmpUrlMapper.setComponentUrl(MainComponent, "/mainComponent");
        captureTemplate(new View(template: "<div></div>")).then((renderTpl) {
          expect(renderTpl.absUrl).toEqual("http://www.app.com/mainComponent");
          async.done();
        });
      }));
      it("should not fill absUrl given no inline template or template url",
          inject([AsyncTestCompleter], (async) {
        cmpUrlMapper.setComponentUrl(MainComponent, "/mainComponent");
        captureTemplate(new View(template: null, templateUrl: null))
            .then((renderTpl) {
          expect(renderTpl.absUrl).toBe(null);
          async.done();
        });
      }));
      it("should fill absUrl given url template", inject([AsyncTestCompleter],
          (async) {
        cmpUrlMapper.setComponentUrl(MainComponent, "/mainComponent");
        captureTemplate(new View(templateUrl: "/someTemplate"))
            .then((renderTpl) {
          expect(renderTpl.absUrl)
              .toEqual("http://www.app.com/mainComponent/someTemplate");
          async.done();
        });
      }));
      it("should fill directive.id", inject([AsyncTestCompleter], (async) {
        captureDirective(MainComponent).then((renderDir) {
          expect(renderDir.id).toEqual(stringify(MainComponent));
          async.done();
        });
      }));
      it("should fill directive.selector", inject([AsyncTestCompleter],
          (async) {
        captureDirective(MainComponent).then((renderDir) {
          expect(renderDir.selector).toEqual("main-comp");
          async.done();
        });
      }));
      it("should fill directive.type for components", inject(
          [AsyncTestCompleter], (async) {
        captureDirective(MainComponent).then((renderDir) {
          expect(renderDir.type)
              .toEqual(renderApi.DirectiveMetadata.COMPONENT_TYPE);
          async.done();
        });
      }));
      it("should fill directive.type for dynamic components", inject(
          [AsyncTestCompleter], (async) {
        captureDirective(SomeDynamicComponentDirective).then((renderDir) {
          expect(renderDir.type)
              .toEqual(renderApi.DirectiveMetadata.COMPONENT_TYPE);
          async.done();
        });
      }));
      it("should fill directive.type for decorator directives", inject(
          [AsyncTestCompleter], (async) {
        captureDirective(SomeDirective).then((renderDir) {
          expect(renderDir.type)
              .toEqual(renderApi.DirectiveMetadata.DIRECTIVE_TYPE);
          async.done();
        });
      }));
      it("should set directive.compileChildren to false for other directives",
          inject([AsyncTestCompleter], (async) {
        captureDirective(MainComponent).then((renderDir) {
          expect(renderDir.compileChildren).toEqual(true);
          async.done();
        });
      }));
      it("should set directive.compileChildren to true for decorator directives",
          inject([AsyncTestCompleter], (async) {
        captureDirective(SomeDirective).then((renderDir) {
          expect(renderDir.compileChildren).toEqual(true);
          async.done();
        });
      }));
      it("should set directive.compileChildren to false for decorator directives",
          inject([AsyncTestCompleter], (async) {
        captureDirective(IgnoreChildrenDirective).then((renderDir) {
          expect(renderDir.compileChildren).toEqual(false);
          async.done();
        });
      }));
      it("should set directive.hostListeners", inject([AsyncTestCompleter],
          (async) {
        captureDirective(DirectiveWithEvents).then((renderDir) {
          expect(renderDir.hostListeners).toEqual(
              MapWrapper.createFromStringMap({"someEvent": "someAction"}));
          async.done();
        });
      }));
      it("should set directive.hostProperties", inject([AsyncTestCompleter],
          (async) {
        captureDirective(DirectiveWithProperties).then((renderDir) {
          expect(renderDir.hostProperties).toEqual(
              MapWrapper.createFromStringMap({"someField": "someProp"}));
          async.done();
        });
      }));
      it("should set directive.bind", inject([AsyncTestCompleter], (async) {
        captureDirective(DirectiveWithBind).then((renderDir) {
          expect(renderDir.properties)
              .toEqual(MapWrapper.createFromStringMap({"a": "b"}));
          async.done();
        });
      }));
      it("should read @Attribute", inject([AsyncTestCompleter], (async) {
        captureDirective(DirectiveWithAttributes).then((renderDir) {
          expect(renderDir.readAttributes).toEqual(["someAttr"]);
          async.done();
        });
      }));
    });
    describe("call ProtoViewFactory", () {
      it("should pass the render protoView", inject([AsyncTestCompleter],
          (async) {
        tplResolver.setView(MainComponent, new View(template: "<div></div>"));
        var renderProtoView = createRenderProtoView();
        var expectedProtoView = createProtoView();
        var compiler = createCompiler([renderProtoView], [expectedProtoView]);
        compiler.compile(MainComponent).then((_) {
          var request = protoViewFactory.requests[0];
          expect(request[1]).toBe(renderProtoView);
          async.done();
        });
      }));
      it("should pass the component binding", inject([AsyncTestCompleter],
          (async) {
        tplResolver.setView(MainComponent, new View(template: "<div></div>"));
        var compiler =
            createCompiler([createRenderProtoView()], [createProtoView()]);
        compiler.compile(MainComponent).then((_) {
          var request = protoViewFactory.requests[0];
          expect(request[0].key.token).toBe(MainComponent);
          async.done();
        });
      }));
      it("should pass the directive bindings", inject([AsyncTestCompleter],
          (async) {
        tplResolver.setView(MainComponent,
            new View(template: "<div></div>", directives: [SomeDirective]));
        var compiler =
            createCompiler([createRenderProtoView()], [createProtoView()]);
        compiler.compile(MainComponent).then((_) {
          var request = protoViewFactory.requests[0];
          var binding = request[2][0];
          expect(binding.key.token).toBe(SomeDirective);
          async.done();
        });
      }));
      it("should use the protoView of the ProtoViewFactory", inject(
          [AsyncTestCompleter], (async) {
        tplResolver.setView(MainComponent, new View(template: "<div></div>"));
        var renderProtoView = createRenderProtoView();
        var expectedProtoView = createProtoView();
        var compiler = createCompiler([renderProtoView], [expectedProtoView]);
        compiler.compile(MainComponent).then((protoViewRef) {
          expect(internalProtoView(protoViewRef)).toBe(expectedProtoView);
          async.done();
        });
      }));
    });
    it("should load nested components", inject([AsyncTestCompleter], (async) {
      tplResolver.setView(MainComponent, new View(template: "<div></div>"));
      tplResolver.setView(NestedComponent, new View(template: "<div></div>"));
      var mainProtoView = createProtoView(
          [createComponentElementBinder(reader, NestedComponent)]);
      var nestedProtoView = createProtoView();
      var compiler = createCompiler([
        createRenderProtoView([createRenderComponentElementBinder(0)]),
        createRenderProtoView()
      ], [mainProtoView, nestedProtoView]);
      compiler.compile(MainComponent).then((protoViewRef) {
        expect(internalProtoView(protoViewRef)).toBe(mainProtoView);
        expect(mainProtoView.elementBinders[0].nestedProtoView)
            .toBe(nestedProtoView);
        async.done();
      });
    }));
    it("should load nested components in viewcontainers", inject(
        [AsyncTestCompleter], (async) {
      tplResolver.setView(MainComponent, new View(template: "<div></div>"));
      tplResolver.setView(NestedComponent, new View(template: "<div></div>"));
      var mainProtoView = createProtoView([createViewportElementBinder(null)]);
      var viewportProtoView = createProtoView(
          [createComponentElementBinder(reader, NestedComponent)]);
      var nestedProtoView = createProtoView();
      var compiler = createCompiler([
        createRenderProtoView([
          createRenderViewportElementBinder(
              createRenderProtoView([createRenderComponentElementBinder(0)]))
        ]),
        createRenderProtoView()
      ], [mainProtoView, viewportProtoView, nestedProtoView]);
      compiler.compile(MainComponent).then((protoViewRef) {
        expect(internalProtoView(protoViewRef)).toBe(mainProtoView);
        expect(mainProtoView.elementBinders[0].nestedProtoView)
            .toBe(viewportProtoView);
        expect(viewportProtoView.elementBinders[0].nestedProtoView)
            .toBe(nestedProtoView);
        async.done();
      });
    }));
    it("should cache compiled components", inject([AsyncTestCompleter],
        (async) {
      tplResolver.setView(MainComponent, new View(template: "<div></div>"));
      var renderProtoView = createRenderProtoView();
      var expectedProtoView = createProtoView();
      var compiler = createCompiler([renderProtoView], [expectedProtoView]);
      compiler.compile(MainComponent).then((protoViewRef) {
        expect(internalProtoView(protoViewRef)).toBe(expectedProtoView);
        return compiler.compile(MainComponent);
      }).then((protoViewRef) {
        expect(internalProtoView(protoViewRef)).toBe(expectedProtoView);
        async.done();
      });
    }));
    it("should re-use components being compiled", inject([AsyncTestCompleter],
        (async) {
      tplResolver.setView(MainComponent, new View(template: "<div></div>"));
      var renderProtoViewCompleter = PromiseWrapper.completer();
      var expectedProtoView = createProtoView();
      var compiler = createCompiler(
          [renderProtoViewCompleter.promise], [expectedProtoView]);
      renderProtoViewCompleter.resolve(createRenderProtoView());
      PromiseWrapper
          .all([
        compiler.compile(MainComponent),
        compiler.compile(MainComponent)
      ])
          .then((protoViewRefs) {
        expect(internalProtoView(protoViewRefs[0])).toBe(expectedProtoView);
        expect(internalProtoView(protoViewRefs[1])).toBe(expectedProtoView);
        async.done();
      });
    }));
    it("should allow recursive components", inject([AsyncTestCompleter],
        (async) {
      tplResolver.setView(MainComponent, new View(template: "<div></div>"));
      var mainProtoView = createProtoView(
          [createComponentElementBinder(reader, MainComponent)]);
      var compiler = createCompiler(
          [createRenderProtoView([createRenderComponentElementBinder(0)])],
          [mainProtoView]);
      compiler.compile(MainComponent).then((protoViewRef) {
        expect(internalProtoView(protoViewRef)).toBe(mainProtoView);
        expect(mainProtoView.elementBinders[0].nestedProtoView)
            .toBe(mainProtoView);
        async.done();
      });
    }));
    it("should create host proto views", inject([AsyncTestCompleter], (async) {
      renderer.spy("createHostProtoView").andCallFake((componentId) {
        return PromiseWrapper.resolve(
            createRenderProtoView([createRenderComponentElementBinder(0)]));
      });
      tplResolver.setView(MainComponent, new View(template: "<div></div>"));
      var rootProtoView = createProtoView(
          [createComponentElementBinder(reader, MainComponent)]);
      var mainProtoView = createProtoView();
      var compiler = createCompiler(
          [createRenderProtoView()], [rootProtoView, mainProtoView]);
      compiler.compileInHost(MainComponent).then((protoViewRef) {
        expect(internalProtoView(protoViewRef)).toBe(rootProtoView);
        expect(rootProtoView.elementBinders[0].nestedProtoView)
            .toBe(mainProtoView);
        async.done();
      });
    }));
    it("should create imperative proto views", inject([AsyncTestCompleter],
        (async) {
      renderer
          .spy("createImperativeComponentProtoView")
          .andCallFake((rendererId) {
        return PromiseWrapper.resolve(createRenderProtoView([]));
      });
      tplResolver.setView(MainComponent, new View(renderer: "some-renderer"));
      var mainProtoView = createProtoView();
      var compiler = createCompiler([], [mainProtoView]);
      compiler.compile(MainComponent).then((protoViewRef) {
        expect(internalProtoView(protoViewRef)).toBe(mainProtoView);
        expect(renderer.spy("createImperativeComponentProtoView"))
            .toHaveBeenCalledWith("some-renderer");
        async.done();
      });
    }));
    it("should throw for non component types", () {
      var compiler = createCompiler([], []);
      expect(() => compiler.compile(SomeDirective)).toThrowError(
          '''Could not load \'${ stringify ( SomeDirective )}\' because it is not a component.''');
    });
  });
}
createDirectiveBinding(reader, type) {
  var meta = reader.read(type);
  return DirectiveBinding.createFromType(meta.type, meta.annotation);
}
createProtoView([elementBinders = null]) {
  var pv = new AppProtoView(null, null, null, null, null);
  if (isBlank(elementBinders)) {
    elementBinders = [];
  }
  pv.elementBinders = elementBinders;
  return pv;
}
createComponentElementBinder(reader, type) {
  var binding = createDirectiveBinding(reader, type);
  return new ElementBinder(0, null, 0, null, binding);
}
createViewportElementBinder(nestedProtoView) {
  var elBinder = new ElementBinder(0, null, 0, null, null);
  elBinder.nestedProtoView = nestedProtoView;
  return elBinder;
}
createRenderProtoView([elementBinders = null]) {
  if (isBlank(elementBinders)) {
    elementBinders = [];
  }
  return new renderApi.ProtoViewDto(elementBinders: elementBinders);
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
@Component(selector: "main-comp")
class MainComponent {}
@Component()
class NestedComponent {}
class RecursiveComponent {}
@Component()
class SomeDynamicComponentDirective {}
@Directive()
class SomeDirective {}
@Directive(compileChildren: false)
class IgnoreChildrenDirective {}
@Directive(hostListeners: const {"someEvent": "someAction"})
class DirectiveWithEvents {}
@Directive(hostProperties: const {"someField": "someProp"})
class DirectiveWithProperties {}
@Directive(properties: const {"a": "b"})
class DirectiveWithBind {}
@Directive()
class DirectiveWithAttributes {
  DirectiveWithAttributes(@Attribute("someAttr") String someAttr) {}
}
@proxy
@IMPLEMENTS(Renderer)
class SpyRenderer extends SpyObject implements Renderer {
  SpyRenderer() : super(Renderer) {
    /* super call moved to initializer */;
  }
  noSuchMethod(m) {
    return super.noSuchMethod(m);
  }
}
class FakeUrlResolver extends UrlResolver {
  FakeUrlResolver() : super() {
    /* super call moved to initializer */;
  }
  String resolve(String baseUrl, String url) {
    if (identical(baseUrl, null) && url == "./") {
      return "http://www.app.com";
    }
    return baseUrl + url;
  }
}
class FakeTemplateResolver extends TemplateResolver {
  Map _cmpTemplates;
  FakeTemplateResolver() : super() {
    /* super call moved to initializer */;
    this._cmpTemplates = MapWrapper.create();
  }
  View resolve(Type component) {
    var template = MapWrapper.get(this._cmpTemplates, component);
    if (isBlank(template)) {
      // dynamic component
      return null;
    }
    return template;
  }
  setView(Type component, View template) {
    MapWrapper.set(this._cmpTemplates, component, template);
  }
}
class FakeProtoViewFactory extends ProtoViewFactory {
  List requests;
  List _results;
  FakeProtoViewFactory(results) : super(null) {
    /* super call moved to initializer */;
    this.requests = [];
    this._results = results;
  }
  AppProtoView createProtoView(parentProtoView,
      DirectiveBinding componentBinding, renderApi.ProtoViewDto renderProtoView,
      List<DirectiveBinding> directives) {
    ListWrapper.push(
        this.requests, [componentBinding, renderProtoView, directives]);
    return ListWrapper.removeAt(this._results, 0);
  }
}
