library angular2.src.core.compiler.directive_metadata;

import "package:angular2/src/facade/lang.dart" show Type;
import "package:angular2/src/facade/collection.dart" show List;
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/di.dart" show ResolvedBinding;

/**
 * Combination of a type with the Directive annotation
 */
class DirectiveMetadata {
  Type type;
  Directive annotation;
  List<ResolvedBinding> resolvedInjectables;
  DirectiveMetadata(Type type, Directive annotation,
      List<ResolvedBinding> resolvedInjectables) {
    this.annotation = annotation;
    this.type = type;
    this.resolvedInjectables = resolvedInjectables;
  }
}
