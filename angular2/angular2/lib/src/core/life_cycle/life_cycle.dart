library angular2.src.core.life_cycle.life_cycle;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/change_detection.dart" show ChangeDetector;
import "package:angular2/src/core/zone/vm_turn_zone.dart" show VmTurnZone;
import "package:angular2/src/core/exception_handler.dart" show ExceptionHandler;
import "package:angular2/src/facade/lang.dart"
    show
        isPresent; /**
 * Provides access to explicitly trigger change detection in an application.
 *
 * By default, `Zone` triggers change detection in Angular on each virtual machine (VM) turn. When testing, or in some
 * limited application use cases, a developer can also trigger change detection with the `lifecycle.tick()` method.
 *
 * Each Angular application has a single `LifeCycle` instance.
 *
 * # Example
 *
 * This is a contrived example, since the bootstrap automatically runs inside of the `Zone`, which invokes
 * `lifecycle.tick()` on your behalf.
 *
 * ```javascript
 * bootstrap(MyApp).then((ref:ComponentRef) => {
 *   var lifeCycle = ref.injector.get(LifeCycle);
 *   var myApp = ref.instance;
 *
 *   ref.doSomething();
 *   lifecycle.tick();
 * });
 * ```
 * @exportedAs angular2/change_detection
 */

@Injectable()
class LifeCycle {
  var _errorHandler;
  ChangeDetector _changeDetector;
  bool _enforceNoNewChanges;
  LifeCycle(ExceptionHandler exceptionHandler,
      [ChangeDetector changeDetector = null,
      bool enforceNoNewChanges = false]) {
    this._errorHandler = (exception, stackTrace) {
      exceptionHandler.call(exception, stackTrace);
      throw exception;
    };
    this._changeDetector = changeDetector;
    this._enforceNoNewChanges = enforceNoNewChanges;
  } /**
   * @private
   */
  registerWith(VmTurnZone zone, [ChangeDetector changeDetector = null]) {
    if (isPresent(changeDetector)) {
      this._changeDetector = changeDetector;
    }
    zone.initCallbacks(
        onErrorHandler: this._errorHandler, onTurnDone: () => this.tick());
  } /**
   *  Invoke this method to explicitly process change detection and its side-effects.
   *
   *  In development mode, `tick()` also performs a second change detection cycle to ensure that no further
   *  changes are detected. If additional changes are picked up during this second cycle, bindings in the app have
   *  side-effects that cannot be resolved in a single change detection pass. In this case, Angular throws an error,
   *  since an Angular application can only have one change detection pass during which all change detection must
   *  complete.
   *
   */
  tick() {
    this._changeDetector.detectChanges();
    if (this._enforceNoNewChanges) {
      this._changeDetector.checkNoChanges();
    }
  }
}
