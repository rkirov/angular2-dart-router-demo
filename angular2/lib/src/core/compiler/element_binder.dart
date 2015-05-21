library angular2.src.core.compiler.element_binder;

import "package:angular2/change_detection.dart" show AST;
import "package:angular2/src/facade/lang.dart"
    show int, isBlank, isPresent, BaseException;
import "element_injector.dart" as eiModule;
import "element_injector.dart" show DirectiveBinding;
import "package:angular2/src/facade/collection.dart" show List, Map;
import "view.dart" as viewModule;

class ElementBinder {
  int index;
  ElementBinder parent;
  int distanceToParent;
  eiModule.ProtoElementInjector protoElementInjector;
  DirectiveBinding componentDirective;
  viewModule.AppProtoView nestedProtoView;
  Map<String, Map<num, AST>> hostListeners;
  ElementBinder(this.index, this.parent, this.distanceToParent,
      this.protoElementInjector, this.componentDirective) {
    if (isBlank(index)) {
      throw new BaseException("null index not allowed.");
    }
    // updated later when events are bound
    this.hostListeners = null;
    // updated later, so we are able to resolve cycles
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
