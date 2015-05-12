library angular2.src.core.compiler.view_container_ref;

import "package:angular2/src/facade/collection.dart" show ListWrapper, List;
import "package:angular2/di.dart" show Injector;
import "package:angular2/src/facade/lang.dart" show isPresent, isBlank;
import "view_manager.dart" as avmModule;
import "element_ref.dart" show ElementRef;
import "view_ref.dart" show ViewRef, ProtoViewRef, internalView;

/**
 * @exportedAs angular2/core
 */
class ViewContainerRef {
  avmModule.AppViewManager _viewManager;
  ElementRef _element;
  ViewContainerRef(avmModule.AppViewManager viewManager, ElementRef element) {
    this._viewManager = viewManager;
    this._element = element;
  }
  _getViews() {
    var vc = internalView(this._element.parentView).viewContainers[
        this._element.boundElementIndex];
    return isPresent(vc) ? vc.views : [];
  }
  void clear() {
    for (var i = this.length - 1; i >= 0; i--) {
      this.remove(i);
    }
  }
  ViewRef get(num index) {
    return new ViewRef(this._getViews()[index]);
  }
  get length {
    return this._getViews().length;
  }
  // TODO(rado): profile and decide whether bounds checks should be added

  // to the methods below.
  ViewRef create([ProtoViewRef protoViewRef = null, num atIndex = -1,
      ElementRef context, Injector injector = null]) {
    if (atIndex == -1) atIndex = this.length;
    return this._viewManager.createViewInContainer(
        this._element, atIndex, protoViewRef, context, injector);
  }
  ViewRef insert(ViewRef viewRef, [num atIndex = -1]) {
    if (atIndex == -1) atIndex = this.length;
    return this._viewManager.attachViewInContainer(
        this._element, atIndex, viewRef);
  }
  indexOf(ViewRef viewRef) {
    return ListWrapper.indexOf(this._getViews(), internalView(viewRef));
  }
  void remove([num atIndex = -1]) {
    if (atIndex == -1) atIndex = this.length - 1;
    this._viewManager.destroyViewInContainer(this._element, atIndex);
  }
  /**
   * The method can be used together with insert to implement a view move, i.e.
   * moving the dom nodes while the directives in the view stay intact.
   */
  ViewRef detach([num atIndex = -1]) {
    if (atIndex == -1) atIndex = this.length - 1;
    return this._viewManager.detachViewInContainer(this._element, atIndex);
  }
}
