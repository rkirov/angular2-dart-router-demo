library angular2.src.directives._if;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/src/core/compiler/view_container_ref.dart"
    show ViewContainerRef;
import "package:angular2/src/core/compiler/view_ref.dart" show ProtoViewRef;
import "package:angular2/src/facade/lang.dart" show isBlank;

/**
 * Removes or recreates a portion of the DOM tree based on an {expression}.
 *
 * If the expression assigned to `if` evaluates to a false value then the element is removed from the
 * DOM, otherwise a clone of the element is reinserted into the DOM.
 *
 * # Example:
 *
 * ```
 * <div *if="errorCount > 0" class="error">
 *   <!-- Error message displayed when the errorCount property on the current context is greater than 0. -->
 *   {{errorCount}} errors detected
 * </div>
 * ```
 *
 * # Syntax
 *
 * - `<div *if="condition">...</div>`
 * - `<div template="if condition">...</div>`
 * - `<template [if]="condition"><div>...</div></template>`
 *
 * @exportedAs angular2/directives
 */
@Directive(selector: "[if]", properties: const {"condition": "if"})
class If {
  ViewContainerRef viewContainer;
  ProtoViewRef protoViewRef;
  bool prevCondition;
  If(ViewContainerRef viewContainer, ProtoViewRef protoViewRef) {
    this.viewContainer = viewContainer;
    this.prevCondition = null;
    this.protoViewRef = protoViewRef;
  }
  set condition(newCondition) {
    if (newCondition && (isBlank(this.prevCondition) || !this.prevCondition)) {
      this.prevCondition = true;
      this.viewContainer.create(this.protoViewRef);
    } else if (!newCondition &&
        (isBlank(this.prevCondition) || this.prevCondition)) {
      this.prevCondition = false;
      this.viewContainer.clear();
    }
  }
}
