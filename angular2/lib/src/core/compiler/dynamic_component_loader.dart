library angular2.src.core.compiler.dynamic_component_loader;

import "package:angular2/di.dart"
    show Key, Injector, ResolvedBinding, Binding, bind, Injectable;
import "compiler.dart" show Compiler;
import "package:angular2/src/facade/lang.dart"
    show Type, BaseException, stringify, isPresent;
import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/src/core/compiler/view_manager.dart"
    show AppViewManager;
import "element_ref.dart" show ElementRef;
import "view_ref.dart" show ViewRef;

/**
 * @exportedAs angular2/view
 */
class ComponentRef {
  ElementRef location;
  dynamic instance;
  Function dispose;
  ComponentRef(this.location, this.instance, this.dispose) {}
  ViewRef get hostView {
    return this.location.parentView;
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
 * Loads a root component that is placed at the first element that matches the
 * component's selector.
 * The loaded component receives injection normally as a hosted view.
 */
  Future<ComponentRef> loadAsRoot(typeOrBinding,
      [overrideSelector = null, Injector injector = null]) {
    return this._compiler
        .compileInHost(this._getBinding(typeOrBinding))
        .then((hostProtoViewRef) {
      var hostViewRef = this._viewManager.createRootHostView(
          hostProtoViewRef, overrideSelector, injector);
      var newLocation = new ElementRef(hostViewRef, 0);
      var component = this._viewManager.getComponent(newLocation);
      var dispose = () {
        this._viewManager.destroyRootHostView(hostViewRef);
      };
      return new ComponentRef(newLocation, component, dispose);
    });
  }
  /**
 * Loads a component into a free host view that is not yet attached to
 * a parent on the render side, although it is attached to a parent in the injector hierarchy.
 * The loaded component receives injection normally as a hosted view.
 */
  Future<ComponentRef> loadIntoNewLocation(
      typeOrBinding, ElementRef parentComponentLocation,
      [Injector injector = null]) {
    return this._compiler
        .compileInHost(this._getBinding(typeOrBinding))
        .then((hostProtoViewRef) {
      var hostViewRef = this._viewManager.createFreeHostView(
          parentComponentLocation, hostProtoViewRef, injector);
      var newLocation = new ElementRef(hostViewRef, 0);
      var component = this._viewManager.getComponent(newLocation);
      var dispose = () {
        this._viewManager.destroyFreeHostView(
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
  Binding _getBinding(typeOrBinding) {
    var binding;
    if (typeOrBinding is Binding) {
      binding = typeOrBinding;
    } else {
      binding = bind(typeOrBinding).toClass(typeOrBinding);
    }
    return binding;
  }
}
