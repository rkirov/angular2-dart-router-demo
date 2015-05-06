library angular2.src.directives._class;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;

@Directive(
    selector: "[class]",
    properties: const {"iterableChanges": "class | keyValDiff"})
class CSSClass {
  var _domEl;
  CSSClass(ElementRef ngEl) {
    this._domEl = ngEl.domElement;
  }
  void _toggleClass(className, enabled) {
    if (enabled) {
      DOM.addClass(this._domEl, className);
    } else {
      DOM.removeClass(this._domEl, className);
    }
  }
  set iterableChanges(changes) {
    if (isPresent(changes)) {
      changes.forEachAddedItem((record) {
        this._toggleClass(record.key, record.currentValue);
      });
      changes.forEachChangedItem((record) {
        this._toggleClass(record.key, record.currentValue);
      });
      changes.forEachRemovedItem((record) {
        if (record.previousValue) {
          DOM.removeClass(this._domEl, record.key);
        }
      });
    }
  }
}
