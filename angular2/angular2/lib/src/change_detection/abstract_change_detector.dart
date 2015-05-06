library angular2.src.change_detection.abstract_change_detector;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "change_detector_ref.dart" show ChangeDetectorRef;
import "interfaces.dart" show ChangeDetector;
import "constants.dart"
    show CHECK_ALWAYS, CHECK_ONCE, CHECKED, DETACHED, ON_PUSH;

class AbstractChangeDetector extends ChangeDetector {
  List lightDomChildren;
  List shadowDomChildren;
  ChangeDetector parent;
  String mode;
  ChangeDetectorRef ref;
  AbstractChangeDetector() : super() {
    /* super call moved to initializer */;
    this.lightDomChildren = [];
    this.shadowDomChildren = [];
    this.ref = new ChangeDetectorRef(this);
    this.mode = null;
  }
  addChild(ChangeDetector cd) {
    ListWrapper.push(this.lightDomChildren, cd);
    cd.parent = this;
  }
  removeChild(ChangeDetector cd) {
    ListWrapper.remove(this.lightDomChildren, cd);
  }
  addShadowDomChild(ChangeDetector cd) {
    ListWrapper.push(this.shadowDomChildren, cd);
    cd.parent = this;
  }
  removeShadowDomChild(ChangeDetector cd) {
    ListWrapper.remove(this.shadowDomChildren, cd);
  }
  remove() {
    this.parent.removeChild(this);
  }
  detectChanges() {
    this._detectChanges(false);
  }
  checkNoChanges() {
    this._detectChanges(true);
  }
  _detectChanges(bool throwOnChange) {
    if (identical(this.mode, DETACHED) || identical(this.mode, CHECKED)) return;
    this.detectChangesInRecords(throwOnChange);
    this._detectChangesInLightDomChildren(throwOnChange);
    this.callOnAllChangesDone();
    this._detectChangesInShadowDomChildren(throwOnChange);
    if (identical(this.mode, CHECK_ONCE)) this.mode = CHECKED;
  }
  detectChangesInRecords(bool throwOnChange) {}
  callOnAllChangesDone() {}
  _detectChangesInLightDomChildren(bool throwOnChange) {
    var c = this.lightDomChildren;
    for (var i = 0; i < c.length; ++i) {
      c[i]._detectChanges(throwOnChange);
    }
  }
  _detectChangesInShadowDomChildren(bool throwOnChange) {
    var c = this.shadowDomChildren;
    for (var i = 0; i < c.length; ++i) {
      c[i]._detectChanges(throwOnChange);
    }
  }
  markAsCheckOnce() {
    this.mode = CHECK_ONCE;
  }
  markPathToRootAsCheckOnce() {
    var c = this;
    while (isPresent(c) && c.mode != DETACHED) {
      if (identical(c.mode, CHECKED)) c.mode = CHECK_ONCE;
      c = c.parent;
    }
  }
}
