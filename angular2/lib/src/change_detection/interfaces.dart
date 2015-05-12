library angular2.src.change_detection.interfaces;

import "package:angular2/src/facade/collection.dart" show List;
import "parser/locals.dart" show Locals;
import "constants.dart" show DEFAULT;
import "binding_record.dart" show BindingRecord;
// HACK: workaround for Traceur behavior.

// It expects all transpiled modules to contain this marker.

// TODO: remove this when we no longer use traceur
var ___esModule = true;
class ProtoChangeDetector {
  ChangeDetector instantiate(dynamic dispatcher) {
    return null;
  }
}
/**
 * Interface used by Angular to control the change detection strategy for an application.
 *
 * Angular implements the following change detection strategies by default:
 *
 * - {@link DynamicChangeDetection}: slower, but does not require `eval()`.
 * - {@link JitChangeDetection}: faster, but requires `eval()`.
 *
 * In JavaScript, you should always use `JitChangeDetection`, unless you are in an environment that
 *has
 * [CSP](https://developer.mozilla.org/en-US/docs/Web/Security/CSP), such as a Chrome Extension.
 *
 * In Dart, use `DynamicChangeDetection` during development. The Angular transformer generates an
 *analog to the
 * `JitChangeDetection` strategy at compile time.
 *
 *
 * See: {@link DynamicChangeDetection}, {@link JitChangeDetection}
 *
 * # Example
 * ```javascript
 * bootstrap(MyApp, [bind(ChangeDetection).toClass(DynamicChangeDetection)]);
 * ```
 * @exportedAs angular2/change_detection
 */
class ChangeDetection {
  ProtoChangeDetector createProtoChangeDetector(String name,
      List<dynamic> bindingRecords, List<dynamic> variableBindings,
      List<dynamic> directiveRecords,
      [String changeControlStrategy = DEFAULT]) {
    return null;
  }
}
class ChangeDispatcher {
  notifyOnBinding(BindingRecord bindingRecord, dynamic value) {}
}
class ChangeDetector {
  ChangeDetector parent;
  String mode;
  addChild(ChangeDetector cd) {}
  addShadowDomChild(ChangeDetector cd) {}
  removeChild(ChangeDetector cd) {}
  removeShadowDomChild(ChangeDetector cd) {}
  remove() {}
  hydrate(dynamic context, Locals locals, dynamic directives) {}
  dehydrate() {}
  markPathToRootAsCheckOnce() {}
  detectChanges() {}
  checkNoChanges() {}
}
