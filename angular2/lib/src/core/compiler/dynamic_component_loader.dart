library angular2.src.core.compiler.dynamic_component_loader;

import "package:angular2/di.dart"
    show Key, Injector, ResolvedBinding, Binding, bind;
import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "compiler.dart" show Compiler;
import "package:angular2/src/facade/lang.dart"
    show Type, BaseException, stringify, isPresent;
import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/src/core/compiler/view_manager.dart"
    show AppViewManager, ComponentCreateResult;
import "element_ref.dart" show ElementRef;

/**
 * @exportedAs angular2/view
 */
class ComponentRef {
  ElementRef location;
  dynamic instance;
  Function _dispose;
  ComponentRef(ElementRef location, dynamic instance, Function dispose) {
    this.location = location;
    this.instance = instance;
    this._dispose = dispose;
  }
  get hostView {
    return this.location.parentView;
  }
  dispose() {
    this._dispose();
  }
}
/**
 * Service for dynamically loading a Component into an arbitrary position in the internal Angular
 * application tree.
 *
 * @exportedAs angular2/view
 */
@Injectable()
class DynamicComponentLoader {
  Compiler _compiler;
  AppViewManager _viewManager;
  DynamicComponentLoader(Compiler compiler, AppViewManager viewManager) {
    this._compiler = compiler;
    this._viewManager = viewManager;
  }
  /**
   * Loads a component into the location given by the provided ElementRef. The loaded component
   * receives injection as if it in the place of the provided ElementRef.
   */
  Future<ComponentRef> loadIntoExistingLocation(
      typeOrBinding, ElementRef location, [Injector injector = null]) {
    var binding = this._getBinding(typeOrBinding);
    return this._compiler.compile(binding.token).then((componentProtoViewRef) {
      this._viewManager.createDynamicComponentView(
          location, componentProtoViewRef, binding, injector);
      var component = this._viewManager.getComponent(location);
      var dispose = () {
        throw new BaseException("Not implemented");
      };
      return new ComponentRef(location, component, dispose);
    });
  }
  /**
   * Loads a component in the element specified by elementSelector. The loaded component receives
   * injection normally as a hosted view.
   */
  Future<ComponentRef> loadIntoNewLocation(
      typeOrBinding, ElementRef parentComponentLocation, String elementSelector,
      [Injector injector = null]) {
    return this._compiler
        .compileInHost(this._getBinding(typeOrBinding))
        .then((hostProtoViewRef) {
      var hostViewRef = this._viewManager.createInPlaceHostView(
          parentComponentLocation, elementSelector, hostProtoViewRef, injector);
      var newLocation = new ElementRef(hostViewRef, 0);
      var component = this._viewManager.getComponent(newLocation);
      var dispose = () {
        this._viewManager.destroyInPlaceHostView(
            parentComponentLocation, hostViewRef);
      };
      return new ComponentRef(newLocation, component, dispose);
    });
  }
  /**
   * Loads a component next to the provided ElementRef. The loaded component receives
   * injection normally as a hosted view.
   */
  Future<ComponentRef> loadNextToExistingLocation(
      typeOrBinding, ElementRef location, [Injector injector = null]) {
    var binding = this._getBinding(typeOrBinding);
    return this._compiler.compileInHost(binding).then((hostProtoViewRef) {
      var viewContainer = this._viewManager.getViewContainer(location);
      var hostViewRef = viewContainer.create(
          hostProtoViewRef, viewContainer.length, null, injector);
      var newLocation = new ElementRef(hostViewRef, 0);
      var component = this._viewManager.getComponent(newLocation);
      var dispose = () {
        var index = viewContainer.indexOf(hostViewRef);
        viewContainer.remove(index);
      };
      return new ComponentRef(newLocation, component, dispose);
    });
  }
  _getBinding(typeOrBinding) {
    var binding;
    if (typeOrBinding is Binding) {
      binding = typeOrBinding;
    } else {
      binding = bind(typeOrBinding).toClass(typeOrBinding);
    }
    return binding;
  }
}
