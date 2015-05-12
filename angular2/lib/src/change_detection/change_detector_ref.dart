library angular2.src.change_detection.change_detector_ref;

import "interfaces.dart" show ChangeDetector;
import "constants.dart" show CHECK_ONCE, DETACHED, CHECK_ALWAYS;
// HACK: workaround for Traceur behavior.

// It expects all transpiled modules to contain this marker.

// TODO: remove this when we no longer use traceur
var ___esModule = true;
/**
 * Controls change detection.
 *
 * {@link ChangeDetectorRef} allows requesting checks for detectors that rely on observables. It
 *also allows detaching and
 * attaching change detector subtrees.
 *
 * @exportedAs angular2/change_detection
 */
class ChangeDetectorRef {
  ChangeDetector _cd;
  ChangeDetectorRef(this._cd) {}
  /**
   * Request to check all ON_PUSH ancestors.
   */
  requestCheck() {
    this._cd.markPathToRootAsCheckOnce();
  }
  /**
   * Detaches the change detector from the change detector tree.
   *
   * The detached change detector will not be checked until it is reattached.
   */
  detach() {
    this._cd.mode = DETACHED;
  }
  /**
   * Reattach the change detector to the change detector tree.
   *
   * This also requests a check of this change detector. This reattached change detector will be
   *checked during the
   * next change detection run.
   */
  reattach() {
    this._cd.mode = CHECK_ALWAYS;
    this.requestCheck();
  }
}
