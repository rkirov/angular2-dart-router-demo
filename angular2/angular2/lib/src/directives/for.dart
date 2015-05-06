library angular2.src.directives._for;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/src/core/compiler/view_container_ref.dart"
    show ViewContainerRef;
import "package:angular2/src/core/compiler/view_ref.dart"
    show ViewRef, ProtoViewRef;
import "package:angular2/src/facade/lang.dart" show isPresent, isBlank;
import "package:angular2/src/facade/collection.dart"
    show
        ListWrapper; /**
 * The `For` directive instantiates a template once per item from an iterable. The context for each
 * instantiated template inherits from the outer context with the given loop variable set to the
 * current item from the iterable.
 *
 * It is possible to alias the `index` to a local variable that will be set to the current loop
 * iteration in the template context.
 *
 * When the contents of the iterator changes, `For` makes the corresponding changes to the DOM:
 *
 * * When an item is added, a new instance of the template is added to the DOM.
 * * When an item is removed, its template instance is removed from the DOM.
 * * When items are reordered, their respective templates are reordered in the DOM.
 *
 * # Example
 *
 * ```
 * <ul>
 *   <li *for="#error of errors; #i = index">
 *     Error {{i}} of {{errors.length}}: {{error.message}}
 *   </li>
 * </ul>
 * ```
 *
 * # Syntax
 *
 * - `<li *for="#item of items; #i = index">...</li>`
 * - `<li template="for #item of items; #i=index">...</li>`
 * - `<template [for]="#item" [of]="items" #i="index"><li>...</li></template>`
 *
 * @exportedAs angular2/directives
 */

@Directive(
    selector: "[for][of]",
    properties: const {"iterableChanges": "of | iterableDiff"})
class For {
  ViewContainerRef viewContainer;
  ProtoViewRef protoViewRef;
  For(ViewContainerRef viewContainer, ProtoViewRef protoViewRef) {
    this.viewContainer = viewContainer;
    this.protoViewRef = protoViewRef;
  }
  set iterableChanges(changes) {
    if (isBlank(changes)) {
      this.viewContainer.clear();
      return;
    } // TODO(rado): check if change detection can produce a change record that is
    // easier to consume than current.
    var recordViewTuples = [];
    changes.forEachRemovedItem((removedRecord) => ListWrapper.push(
        recordViewTuples, new RecordViewTuple(removedRecord, null)));
    changes.forEachMovedItem((movedRecord) => ListWrapper.push(
        recordViewTuples, new RecordViewTuple(movedRecord, null)));
    var insertTuples = For.bulkRemove(recordViewTuples, this.viewContainer);
    changes.forEachAddedItem((addedRecord) =>
        ListWrapper.push(insertTuples, new RecordViewTuple(addedRecord, null)));
    For.bulkInsert(insertTuples, this.viewContainer, this.protoViewRef);
    for (var i = 0; i < insertTuples.length; i++) {
      this.perViewChange(insertTuples[i].view, insertTuples[i].record);
    }
  }
  perViewChange(view, record) {
    view.setLocal("\$implicit", record.item);
    view.setLocal("index", record.currentIndex);
  }
  static bulkRemove(tuples, viewContainer) {
    tuples.sort((a, b) => a.record.previousIndex - b.record.previousIndex);
    var movedTuples = [];
    for (var i = tuples.length - 1; i >= 0; i--) {
      var tuple = tuples[i]; // separate moved views from removed views.
      if (isPresent(tuple.record.currentIndex)) {
        tuple.view = viewContainer.detach(tuple.record.previousIndex);
        ListWrapper.push(movedTuples, tuple);
      } else {
        viewContainer.remove(tuple.record.previousIndex);
      }
    }
    return movedTuples;
  }
  static bulkInsert(tuples, viewContainer, protoViewRef) {
    tuples.sort((a, b) => a.record.currentIndex - b.record.currentIndex);
    for (var i = 0; i < tuples.length; i++) {
      var tuple = tuples[i];
      if (isPresent(tuple.view)) {
        viewContainer.insert(tuple.view, tuple.record.currentIndex);
      } else {
        tuple.view =
            viewContainer.create(protoViewRef, tuple.record.currentIndex);
      }
    }
    return tuples;
  }
}
class RecordViewTuple {
  ViewRef view;
  dynamic record;
  RecordViewTuple(record, view) {
    this.record = record;
    this.view = view;
  }
}
