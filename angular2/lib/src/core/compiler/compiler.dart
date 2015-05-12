library angular2.src.core.compiler.compiler;

import "package:angular2/di.dart" show Binding;
import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/lang.dart"
    show Type, isBlank, isPresent, BaseException, normalizeBlank, stringify;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map, MapWrapper;
import "directive_metadata_reader.dart" show DirectiveMetadataReader;
import "../annotations_impl/annotations.dart" show Component, Directive;
import "view.dart" show AppProtoView;
import "view_ref.dart" show ProtoViewRef;
import "element_injector.dart" show DirectiveBinding;
import "template_resolver.dart" show TemplateResolver;
import "../annotations_impl/view.dart" show View;
import "component_url_mapper.dart" show ComponentUrlMapper;
import "proto_view_factory.dart" show ProtoViewFactory;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/render/api.dart" as renderApi;

/**
 * Cache that stores the AppProtoView of the template of a component.
 * Used to prevent duplicate work and resolve cyclic dependencies.
 */
@Injectable()
class CompilerCache {
  Map _cache;
  CompilerCache() {
    this._cache = MapWrapper.create();
  }
  void set(Type component, AppProtoView protoView) {
    MapWrapper.set(this._cache, component, protoView);
  }
  AppProtoView get(Type component) {
    var result = MapWrapper.get(this._cache, component);
    return normalizeBlank(result);
  }
  void clear() {
    MapWrapper.clear(this._cache);
  }
}
/**
 * @exportedAs angular2/view
 */
@Injectable()
class Compiler {
  DirectiveMetadataReader _reader;
  CompilerCache _compilerCache;
  Map<Type, Future> _compiling;
  TemplateResolver _templateResolver;
  ComponentUrlMapper _componentUrlMapper;
  UrlResolver _urlResolver;
  String _appUrl;
  renderApi.RenderCompiler _render;
  ProtoViewFactory _protoViewFactory;
  Compiler(DirectiveMetadataReader reader, CompilerCache cache,
      TemplateResolver templateResolver, ComponentUrlMapper componentUrlMapper,
      UrlResolver urlResolver, renderApi.RenderCompiler render,
      ProtoViewFactory protoViewFactory) {
    this._reader = reader;
    this._compilerCache = cache;
    this._compiling = MapWrapper.create();
    this._templateResolver = templateResolver;
    this._componentUrlMapper = componentUrlMapper;
    this._urlResolver = urlResolver;
    this._appUrl = urlResolver.resolve(null, "./");
    this._render = render;
    this._protoViewFactory = protoViewFactory;
  }
  DirectiveBinding _bindDirective(directiveTypeOrBinding) {
    if (directiveTypeOrBinding is DirectiveBinding) {
      return directiveTypeOrBinding;
    } else if (directiveTypeOrBinding is Binding) {
      var meta = this._reader.read(directiveTypeOrBinding.token);
      return DirectiveBinding.createFromBinding(
          directiveTypeOrBinding, meta.annotation);
    } else {
      var meta = this._reader.read(directiveTypeOrBinding);
      return DirectiveBinding.createFromType(meta.type, meta.annotation);
    }
  }
  // Create a hostView as if the compiler encountered <hostcmp></hostcmp>.

  // Used for bootstrapping.
  Future<ProtoViewRef> compileInHost(dynamic componentTypeOrBinding) {
    var componentBinding = this._bindDirective(componentTypeOrBinding);
    this._assertTypeIsComponent(componentBinding);
    var directiveMetadata = Compiler.buildRenderDirective(componentBinding);
    return this._render.compileHost(directiveMetadata).then((hostRenderPv) {
      return this._compileNestedProtoViews(
          null, null, hostRenderPv, [componentBinding], true);
    }).then((appProtoView) {
      return new ProtoViewRef(appProtoView);
    });
  }
  Future<ProtoViewRef> compile(Type component) {
    var componentBinding = this._bindDirective(component);
    this._assertTypeIsComponent(componentBinding);
    var protoView = this._compile(componentBinding);
    var pvPromise = PromiseWrapper.isPromise(protoView)
        ? protoView
        : PromiseWrapper.resolve(protoView);
    return pvPromise.then((appProtoView) {
      return new ProtoViewRef(appProtoView);
    });
  }
  // TODO(vicb): union type return AppProtoView or Promise<AppProtoView>
  _compile(DirectiveBinding componentBinding) {
    var component = componentBinding.key.token;
    var protoView = this._compilerCache.get(component);
    if (isPresent(protoView)) {
      // The component has already been compiled into an AppProtoView,

      // returns a plain AppProtoView, not wrapped inside of a Promise.

      // Needed for recursive components.
      return protoView;
    }
    var pvPromise = MapWrapper.get(this._compiling, component);
    if (isPresent(pvPromise)) {
      // The component is already being compiled, attach to the existing Promise

      // instead of re-compiling the component.

      // It happens when a template references a component multiple times.
      return pvPromise;
    }
    var template = this._templateResolver.resolve(component);
    if (isBlank(template)) {
      return null;
    }
    var directives = ListWrapper.map(this._flattenDirectives(template),
        (directive) => this._bindDirective(directive));
    var renderTemplate =
        this._buildRenderTemplate(component, template, directives);
    pvPromise = this._render.compile(renderTemplate).then((renderPv) {
      return this._compileNestedProtoViews(
          null, componentBinding, renderPv, directives, true);
    });
    MapWrapper.set(this._compiling, component, pvPromise);
    return pvPromise;
  }
  // TODO(tbosch): union type return AppProtoView or Promise<AppProtoView>
  _compileNestedProtoViews(parentProtoView, componentBinding, renderPv,
      directives, isComponentRootView) {
    var nestedPVPromises = [];
    var protoView = this._protoViewFactory.createProtoView(
        parentProtoView, componentBinding, renderPv, directives);
    if (isComponentRootView && isPresent(componentBinding)) {
      // Populate the cache before compiling the nested components,

      // so that components can reference themselves in their template.
      var component = componentBinding.key.token;
      this._compilerCache.set(component, protoView);
      MapWrapper.delete(this._compiling, component);
    }
    var binderIndex = 0;
    ListWrapper.forEach(protoView.elementBinders, (elementBinder) {
      var nestedComponent = elementBinder.componentDirective;
      var nestedRenderProtoView =
          renderPv.elementBinders[binderIndex].nestedProtoView;
      var elementBinderDone = (nestedPv) {
        elementBinder.nestedProtoView = nestedPv;
      };
      var nestedCall = null;
      if (isPresent(nestedComponent)) {
        nestedCall = this._compile(nestedComponent);
      } else if (isPresent(nestedRenderProtoView)) {
        nestedCall = this._compileNestedProtoViews(protoView, componentBinding,
            nestedRenderProtoView, directives, false);
      }
      if (PromiseWrapper.isPromise(nestedCall)) {
        ListWrapper.push(nestedPVPromises, nestedCall.then(elementBinderDone));
      } else if (isPresent(nestedCall)) {
        elementBinderDone(nestedCall);
      }
      binderIndex++;
    });
    var protoViewDone = (_) {
      return protoView;
    };
    if (nestedPVPromises.length > 0) {
      return PromiseWrapper.all(nestedPVPromises).then(protoViewDone);
    } else {
      return protoViewDone(null);
    }
  }
  renderApi.ViewDefinition _buildRenderTemplate(component, view, directives) {
    var componentUrl = this._urlResolver.resolve(
        this._appUrl, this._componentUrlMapper.getUrl(component));
    var templateAbsUrl = null;
    if (isPresent(view.templateUrl)) {
      templateAbsUrl =
          this._urlResolver.resolve(componentUrl, view.templateUrl);
    } else if (isPresent(view.template)) {
      // Note: If we have an inline template, we also need to send

      // the url for the component to the render so that it

      // is able to resolve urls in stylesheets.
      templateAbsUrl = componentUrl;
    }
    return new renderApi.ViewDefinition(
        componentId: stringify(component),
        absUrl: templateAbsUrl,
        template: view.template,
        directives: ListWrapper.map(directives, Compiler.buildRenderDirective));
  }
  static renderApi.DirectiveMetadata buildRenderDirective(directiveBinding) {
    var ann = directiveBinding.annotation;
    var renderType;
    var compileChildren = ann.compileChildren;
    if (ann is Component) {
      renderType = renderApi.DirectiveMetadata.COMPONENT_TYPE;
    } else {
      renderType = renderApi.DirectiveMetadata.DIRECTIVE_TYPE;
    }
    var readAttributes = [];
    ListWrapper.forEach(directiveBinding.dependencies, (dep) {
      if (isPresent(dep.attributeName)) {
        ListWrapper.push(readAttributes, dep.attributeName);
      }
    });
    return new renderApi.DirectiveMetadata(
        id: stringify(directiveBinding.key.token),
        type: renderType,
        selector: ann.selector,
        compileChildren: compileChildren,
        hostListeners: isPresent(ann.hostListeners)
            ? MapWrapper.createFromStringMap(ann.hostListeners)
            : null,
        hostProperties: isPresent(ann.hostProperties)
            ? MapWrapper.createFromStringMap(ann.hostProperties)
            : null,
        hostAttributes: isPresent(ann.hostAttributes)
            ? MapWrapper.createFromStringMap(ann.hostAttributes)
            : null,
        hostActions: isPresent(ann.hostActions)
            ? MapWrapper.createFromStringMap(ann.hostActions)
            : null,
        properties: isPresent(ann.properties)
            ? MapWrapper.createFromStringMap(ann.properties)
            : null,
        readAttributes: readAttributes);
  }
  List<Type> _flattenDirectives(View template) {
    if (isBlank(template.directives)) return [];
    var directives = [];
    this._flattenList(template.directives, directives);
    return directives;
  }
  void _flattenList(List<dynamic> tree, List<Type> out) {
    for (var i = 0; i < tree.length; i++) {
      var item = tree[i];
      if (ListWrapper.isList(item)) {
        this._flattenList(item, out);
      } else {
        ListWrapper.push(out, item);
      }
    }
  }
  void _assertTypeIsComponent(DirectiveBinding directiveBinding) {
    if (!(directiveBinding.annotation is Component)) {
      throw new BaseException(
          '''Could not load \'${ stringify ( directiveBinding . key . token )}\' because it is not a component.''');
    }
  }
}
