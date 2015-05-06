library angular2.src.test_lib.test_bed;

import "package:angular2/di.dart" show Injector, bind;
import "package:angular2/src/facade/lang.dart"
    show Type, isPresent, BaseException;
import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/src/facade/lang.dart" show isBlank;
import "package:angular2/src/facade/collection.dart" show List;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/compiler/template_resolver.dart"
    show TemplateResolver;
import "package:angular2/src/core/compiler/view.dart" show AppView;
import "package:angular2/src/core/compiler/view_ref.dart" show internalView;
import "package:angular2/src/core/compiler/dynamic_component_loader.dart"
    show DynamicComponentLoader, ComponentRef;
import "utils.dart" show queryView, viewRootNodes, el;
import "lang_utils.dart"
    show instantiateType, getTypeOf; /**
 * @exportedAs angular2/test
 */

class TestBed {
  Injector _injector;
  TestBed(Injector injector) {
    this._injector = injector;
  } /**
   * Overrides the {@link View} of a {@link Component}.
   *
   * @see setInlineTemplate() to only override the html
   *
   * @param {Type} component
   * @param {ViewDefinition} template
   */
  void overrideView(Type component, View template) {
    this._injector.get(TemplateResolver).setView(component, template);
  } /**
   * Overrides only the html of a {@link Component}.
   * All the other propoerties of the component's {@link View} are preserved.
   *
   * @param {Type} component
   * @param {string} html
   */
  void setInlineTemplate(Type component, String html) {
    this._injector.get(TemplateResolver).setInlineTemplate(component, html);
  } /**
   * Overrides the directives from the component {@link View}.
   *
   * @param {Type} component
   * @param {Type} from
   * @param {Type} to
   */
  void overrideDirective(Type component, Type from, Type to) {
    this._injector.get(TemplateResolver).overrideTemplateDirective(
        component, from, to);
  } /**
   * Creates an `AppView` for the given component.
   *
   * Only either a component or a context needs to be specified but both can be provided for
   * advanced use cases (ie subclassing the context).
   *
   * @param {Type} component
   * @param {*} context
   * @param {string} html Use as the component template when specified (shortcut for setInlineTemplate)
   * @return {Promise<ViewProxy>}
   */
  Future<AppView> createView(Type component, {context: null, html: null}) {
    if (isBlank(component) && isBlank(context)) {
      throw new BaseException(
          "You must specified at least a component or a context");
    }
    if (isBlank(component)) {
      component = getTypeOf(context);
    } else if (isBlank(context)) {
      context = instantiateType(component);
    }
    if (isPresent(html)) {
      this.setInlineTemplate(component, html);
    }
    var rootEl = el("<div></div>");
    var componentBinding = bind(component).toValue(context);
    return this._injector
        .get(DynamicComponentLoader)
        .loadIntoNewLocation(componentBinding, null, rootEl, this._injector)
        .then((hostComponentRef) {
      return new ViewProxy(hostComponentRef);
    });
  }
} /**
 * Proxy to `AppView` return by `createView` in {@link TestBed} which offers a high level API for tests.
 */
class ViewProxy {
  ComponentRef _componentRef;
  AppView _view;
  ViewProxy(ComponentRef componentRef) {
    this._componentRef = componentRef;
    this._view = internalView(componentRef.hostView).componentChildViews[0];
  }
  dynamic get context {
    return this._view.context;
  }
  List get rootNodes {
    return viewRootNodes(this._view);
  }
  void detectChanges() {
    this._view.changeDetector.detectChanges();
    this._view.changeDetector.checkNoChanges();
  }
  querySelector(selector) {
    return queryView(this._view, selector);
  }
  destroy() {
    this._componentRef.dispose();
  } /**
   * @returns `AppView` returns the underlying `AppView`.
   *
   * Prefer using the other methods which hide implementation details.
   */
  AppView get rawView {
    return this._view;
  }
}
