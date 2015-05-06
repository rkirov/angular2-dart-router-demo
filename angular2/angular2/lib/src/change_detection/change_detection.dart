library angular2.src.change_detection.change_detection;

import "proto_change_detector.dart"
    show DynamicProtoChangeDetector, JitProtoChangeDetector;
import "pipes/pipe.dart" show PipeFactory;
import "pipes/pipe_registry.dart" show PipeRegistry;
import "pipes/iterable_changes.dart" show IterableChangesFactory;
import "pipes/keyvalue_changes.dart" show KeyValueChangesFactory;
import "pipes/async_pipe.dart" show AsyncPipeFactory;
import "pipes/null_pipe.dart" show NullPipeFactory;
import "binding_record.dart" show BindingRecord;
import "directive_record.dart" show DirectiveRecord;
import "constants.dart" show DEFAULT;
import "interfaces.dart" show ChangeDetection, ProtoChangeDetector;
import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/collection.dart"
    show
        List; /**
 * Structural diffing for `Object`s and `Map`s.
 *
 * @exportedAs angular2/pipes
 */

List<PipeFactory> keyValDiff = [
  new KeyValueChangesFactory(),
  new NullPipeFactory()
]; /**
 * Structural diffing for `Iterable` types such as `Array`s.
 *
 * @exportedAs angular2/pipes
 */
List<PipeFactory> iterableDiff = [
  new IterableChangesFactory(),
  new NullPipeFactory()
]; /**
 * Async binding to such types as Observable.
 *
 * @exportedAs angular2/pipes
 */
List<PipeFactory> async = [new AsyncPipeFactory(), new NullPipeFactory()];
Map<String, List<PipeFactory>> defaultPipes = {
  "iterableDiff": iterableDiff,
  "keyValDiff": keyValDiff,
  "async": async
}; /**
 * Implements change detection that does not require `eval()`.
 *
 * This is slower than {@link JitChangeDetection}.
 *
 * @exportedAs angular2/change_detection
 */
@Injectable()
class DynamicChangeDetection extends ChangeDetection {
  PipeRegistry registry;
  DynamicChangeDetection(PipeRegistry registry) : super() {
    /* super call moved to initializer */;
    this.registry = registry;
  }
  ProtoChangeDetector createProtoChangeDetector(String name,
      List<BindingRecord> bindingRecords, List<String> variableBindings,
      List<DirectiveRecord> directiveRecords,
      [String changeControlStrategy = DEFAULT]) {
    return new DynamicProtoChangeDetector(this.registry, bindingRecords,
        variableBindings, directiveRecords, changeControlStrategy);
  }
} /**
 * Implements faster change detection, by generating source code.
 *
 * This requires `eval()`. For change detection that does not require `eval()`, see {@link DynamicChangeDetection}.
 *
 * @exportedAs angular2/change_detection
 */
@Injectable()
class JitChangeDetection extends ChangeDetection {
  PipeRegistry registry;
  JitChangeDetection(PipeRegistry registry) : super() {
    /* super call moved to initializer */;
    this.registry = registry;
  }
  ProtoChangeDetector createProtoChangeDetector(String name,
      List<BindingRecord> bindingRecords, List<String> variableBindings,
      List<DirectiveRecord> directiveRecords,
      [String changeControlStrategy = DEFAULT]) {
    return new JitProtoChangeDetector(this.registry, bindingRecords,
        variableBindings, directiveRecords, changeControlStrategy);
  }
}
var defaultPipeRegistry = new PipeRegistry(defaultPipes);
