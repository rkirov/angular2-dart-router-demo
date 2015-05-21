library angular2.src.core.compiler.compiler;

import "package:angular2/di.dart" show Binding, resolveForwardRef, Injectable;
import "package:angular2/src/facade/lang.dart"
    show Type, isBlank, isPresent, BaseException, normalizeBlank, stringify;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map, MapWrapper;
import "directive_resolver.dart" show DirectiveResolver;
import "view.dart" show AppProtoView;
import "element_binder.dart" show ElementBinder;
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
  Map<Type, AppProtoView> _cache;
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
  DirectiveResolver _reader;
  CompilerCache _compilerCache;
  Map<Type, Future<AppProtoView>> _compiling;
  TemplateResolver _templateResolver;
  ComponentUrlMapper _componentUrlMapper;
  UrlResolver _urlResolver;
  String _appUrl;
  renderApi.RenderCompiler _render;
  ProtoViewFactory _protoViewFactory;
  Compiler(DirectiveResolver reader, CompilerCache cache,
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
      var annotation = this._reader.resolve(directiveTypeOrBinding.token);
      return DirectiveBinding.createFromBinding(
          directiveTypeOrBinding, annotation);
    } else {
      var annotation = this._reader.resolve(directiveTypeOrBinding);
      return DirectiveBinding.createFromType(
          directiveTypeOrBinding, annotation);
    }
  }
  // Create a hostView as if the compiler encountered <hostcmp></hostcmp>.

  // Used for bootstrapping.
  Future<ProtoViewRef> compileInHost(
      dynamic /* Type | Binding */ componentTypeOrBinding) {
    var componentBinding = this._bindDirective(componentTypeOrBinding);
    Compiler._assertTypeIsComponent(componentBinding);
    var directiveMetadata = componentBinding.metadata;
    return this._render.compileHost(directiveMetadata).then((hostRenderPv) {
      return this._compileNestedProtoViews(
          componentBinding, hostRenderPv, [componentBinding]);
    }).then((appProtoView) {
      return new ProtoViewRef(appProtoView);
    });
  }
  Future<ProtoViewRef> compile(Type component) {
    var componentBinding = this._bindDirective(component);
    Compiler._assertTypeIsComponent(componentBinding);
    var pvOrPromise = this._compile(componentBinding);
    var pvPromise = PromiseWrapper.isPromise(pvOrPromise)
        ? (pvOrPromise as Future<AppProtoView>)
        : PromiseWrapper.resolve(pvOrPromise);
    return pvPromise.then((appProtoView) {
      return new ProtoViewRef(appProtoView);
    });
  }
  dynamic /* Future < AppProtoView > | AppProtoView */ _compile(
      DirectiveBinding componentBinding) {
    var component = (componentBinding.key.token as Type);
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
    var directives = this._flattenDirectives(template);
    for (var i = 0; i < directives.length; i++) {
      if (!Compiler._isValidDirective(directives[i])) {
        throw new BaseException(
            '''Unexpected directive value \'${ stringify ( directives [ i ] )}\' on the View of component \'${ stringify ( component )}\'''');
      }
    }
    var boundDirectives = ListWrapper.map(
        directives, (directive) => this._bindDirective(directive));
    var renderTemplate =
        this._buildRenderTemplate(component, template, boundDirectives);
    pvPromise = this._render.compile(renderTemplate).then((renderPv) {
      return this._compileNestedProtoViews(
          componentBinding, renderPv, boundDirectives);
    });
    MapWrapper.set(this._compiling, component, pvPromise);
    return pvPromise;
  }
  dynamic /* Future < AppProtoView > | AppProtoView */ _compileNestedProtoViews(
      componentBinding, renderPv, directives) {
    var protoViews = this._protoViewFactory.createAppProtoViews(
        componentBinding, renderPv, directives);
    var protoView = protoViews[0];
    // TODO(tbosch): we should be caching host protoViews as well!

    // -> need a separate cache for this...
    if (identical(renderPv.type, renderApi.ProtoViewDto.COMPONENT_VIEW_TYPE) &&
        isPresent(componentBinding)) {
      // Populate the cache before compiling the nested components,

      // so that components can reference themselves in their template.
      var component = componentBinding.key.token;
      this._compilerCache.set(component, protoView);
      MapWrapper.delete(this._compiling, component);
    }
    var nestedPVPromises = [];
    ListWrapper.forEach(this._collectComponentElementBinders(protoViews),
        (elementBinder) {
      var nestedComponent = elementBinder.componentDirective;
      var elementBinderDone = (AppProtoView nestedPv) {
        elementBinder.nestedProtoView = nestedPv;
      };
      var nestedCall = this._compile(nestedComponent);
      if (PromiseWrapper.isPromise(nestedCall)) {
        ListWrapper.push(nestedPVPromises,
            ((nestedCall as Future<AppProtoView>)).then(elementBinderDone));
      } else if (isPresent(nestedCall)) {
        elementBinderDone((nestedCall as AppProtoView));
      }
    });
    if (nestedPVPromises.length > 0) {
      return PromiseWrapper.all(nestedPVPromises).then((_) => protoView);
    } else {
      return protoView;
    }
  }
  List<ElementBinder> _collectComponentElementBinders(
      List<AppProtoView> protoViews) {
    var componentElementBinders = [];
    ListWrapper.forEach(protoViews, (protoView) {
      ListWrapper.forEach(protoView.elementBinders, (elementBinder) {
        if (isPresent(elementBinder.componentDirective)) {
          ListWrapper.push(componentElementBinders, elementBinder);
        }
      });
    });
    return componentElementBinders;
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
        directives: ListWrapper.map(
            directives, (directiveBinding) => directiveBinding.metadata));
  }
  List<Type> _flattenDirectives(View template) {
    if (isBlank(template.directives)) return [];
    var directives = [];
    this._flattenList(template.directives, directives);
    return directives;
  }
  void _flattenList(List<dynamic> tree,
      List<dynamic /* Type | Binding | List < dynamic > */ > out) {
    for (var i = 0; i < tree.length; i++) {
      var item = resolveForwardRef(tree[i]);
      if (ListWrapper.isList(item)) {
        this._flattenList(item, out);
      } else {
        ListWrapper.push(out, item);
      }
    }
  }
  static bool _isValidDirective(dynamic /* Type | Binding */ value) {
    return isPresent(value) && (value is Type || value is Binding);
  }
  static void _assertTypeIsComponent(DirectiveBinding directiveBinding) {
    if (!identical(directiveBinding.metadata.type,
        renderApi.DirectiveMetadata.COMPONENT_TYPE)) {
      throw new BaseException(
          '''Could not load \'${ stringify ( directiveBinding . key . token )}\' because it is not a component.''');
    }
  }
}
