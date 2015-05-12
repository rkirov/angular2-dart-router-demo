library angular2.src.mock.template_resolver_mock;

import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, ListWrapper;
import "package:angular2/src/facade/lang.dart"
    show Type, isPresent, BaseException, stringify, isBlank;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/compiler/template_resolver.dart"
    show TemplateResolver;

class MockTemplateResolver extends TemplateResolver {
  Map<Type, View> _templates;
  Map<Type, String> _inlineTemplates;
  Map<Type, View> _templateCache;
  Map<Type, Type> _directiveOverrides;
  MockTemplateResolver() : super() {
    /* super call moved to initializer */;
    this._templates = MapWrapper.create();
    this._inlineTemplates = MapWrapper.create();
    this._templateCache = MapWrapper.create();
    this._directiveOverrides = MapWrapper.create();
  }
  /**
   * Overrides the {@link View} for a component.
   *
   * @param {Type} component
   * @param {ViewDefinition} view
   */
  void setView(Type component, View view) {
    this._checkOverrideable(component);
    MapWrapper.set(this._templates, component, view);
  }
  /**
   * Overrides the inline template for a component - other configuration remains unchanged.
   *
   * @param {Type} component
   * @param {string} template
   */
  void setInlineTemplate(Type component, String template) {
    this._checkOverrideable(component);
    MapWrapper.set(this._inlineTemplates, component, template);
  }
  /**
   * Overrides a directive from the component {@link View}.
   *
   * @param {Type} component
   * @param {Type} from
   * @param {Type} to
   */
  void overrideTemplateDirective(Type component, Type from, Type to) {
    this._checkOverrideable(component);
    var overrides = MapWrapper.get(this._directiveOverrides, component);
    if (isBlank(overrides)) {
      overrides = MapWrapper.create();
      MapWrapper.set(this._directiveOverrides, component, overrides);
    }
    MapWrapper.set(overrides, from, to);
  }
  /**
   * Returns the {@link View} for a component:
   * - Set the {@link View} to the overridden template when it exists or fallback to the default `TemplateResolver`,
   *   see `setView`.
   * - Override the directives, see `overrideTemplateDirective`.
   * - Override the @View definition, see `setInlineTemplate`.
   *
   * @param component
   * @returns {ViewDefinition}
   */
  View resolve(Type component) {
    var view = MapWrapper.get(this._templateCache, component);
    if (isPresent(view)) return view;
    view = MapWrapper.get(this._templates, component);
    if (isBlank(view)) {
      view = super.resolve(component);
    }
    if (isBlank(view)) {
      // dynamic components
      return null;
    }
    var directives = view.directives;
    var overrides = MapWrapper.get(this._directiveOverrides, component);
    if (isPresent(overrides) && isPresent(directives)) {
      directives = ListWrapper.clone(view.directives);
      MapWrapper.forEach(overrides, (to, from) {
        var srcIndex = directives.indexOf(from);
        if (srcIndex == -1) {
          throw new BaseException(
              '''Overriden directive ${ stringify ( from )} not found in the template of ${ stringify ( component )}''');
        }
        directives[srcIndex] = to;
      });
      view = new View(
          template: view.template,
          templateUrl: view.templateUrl,
          directives: directives);
    }
    var inlineTemplate = MapWrapper.get(this._inlineTemplates, component);
    if (isPresent(inlineTemplate)) {
      view = new View(
          template: inlineTemplate,
          templateUrl: null,
          directives: view.directives);
    }
    MapWrapper.set(this._templateCache, component, view);
    return view;
  }
  /**
   * Once a component has been compiled, the AppProtoView is stored in the compiler cache.
   *
   * Then it should not be possible to override the component configuration after the component
   * has been compiled.
   *
   * @param {Type} component
   */
  void _checkOverrideable(Type component) {
    var cached = MapWrapper.get(this._templateCache, component);
    if (isPresent(cached)) {
      throw new BaseException(
          '''The component ${ stringify ( component )} has already been compiled, its configuration can not be changed''');
    }
  }
}
