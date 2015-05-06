library angular2.src.core.compiler.element_binder;

import "package:angular2/src/facade/lang.dart"
    show int, isBlank, isPresent, BaseException;
import "element_injector.dart" as eiModule;
import "element_injector.dart" show DirectiveBinding;
import "package:angular2/src/facade/collection.dart" show List, Map;
import "view.dart" as viewModule;

class ElementBinder {
  eiModule.ProtoElementInjector protoElementInjector;
  DirectiveBinding componentDirective;
  viewModule.AppProtoView nestedProtoView;
  Map hostListeners;
  ElementBinder parent;
  int index;
  int distanceToParent;
  ElementBinder(int index, ElementBinder parent, int distanceToParent,
      eiModule.ProtoElementInjector protoElementInjector,
      DirectiveBinding componentDirective) {
    if (isBlank(index)) {
      throw new BaseException("null index not allowed.");
    }
    this.protoElementInjector = protoElementInjector;
    this.componentDirective = componentDirective;
    this.parent = parent;
    this.index = index;
    this.distanceToParent =
        distanceToParent; // updated later when events are bound
    this.hostListeners =
        null; // updated later, so we are able to resolve cycles
    this.nestedProtoView = null;
  }
  hasStaticComponent() {
    return isPresent(this.componentDirective) &&
        isPresent(this.nestedProtoView);
  }
  hasDynamicComponent() {
    return isPresent(this.componentDirective) && isBlank(this.nestedProtoView);
  }
  hasEmbeddedProtoView() {
    return !isPresent(this.componentDirective) &&
        isPresent(this.nestedProtoView);
  }
}
