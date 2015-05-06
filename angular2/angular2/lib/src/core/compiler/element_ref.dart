library angular2.src.core.compiler.element_ref;

import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/lang.dart" show normalizeBlank;
import "view_ref.dart" show ViewRef;
import "package:angular2/src/render/dom/direct_dom_renderer.dart"
    show DirectDomViewRef; /**
 * @exportedAs angular2/view
 */

class ElementRef {
  ViewRef parentView;
  num boundElementIndex;
  ElementRef(ViewRef parentView, num boundElementIndex) {
    this.parentView = parentView;
    this.boundElementIndex = boundElementIndex;
  } /**
   * Exposes the underlying DOM element.
   * (DEPRECATED way of accessing the DOM, replacement coming)
   */
  // TODO(tbosch): Here we expose the real DOM element.
  // We need a more general way to read/write to the DOM element
  // via a proper abstraction in the render layer
  get domElement {
    DirectDomViewRef renderViewRef = this.parentView.render;
    return renderViewRef.delegate.boundElements[this.boundElementIndex];
  } /**
   * Gets an attribute from the underlying DOM element.
   * (DEPRECATED way of accessing the DOM, replacement coming)
   */
  // TODO(tbosch): Here we expose the real DOM element.
  // We need a more general way to read/write to the DOM element
  // via a proper abstraction in the render layer
  String getAttribute(String name) {
    return normalizeBlank(DOM.getAttribute(this.domElement, name));
  }
}
