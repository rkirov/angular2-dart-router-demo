library angular2.src.change_detection.change_detection;

import "proto_change_detector.dart"
    show DynamicProtoChangeDetector, JitProtoChangeDetector;
import "pipes/pipe.dart" show PipeFactory;
import "pipes/pipe_registry.dart" show PipeRegistry;
import "pipes/iterable_changes.dart" show IterableChangesFactory;
import "pipes/keyvalue_changes.dart" show KeyValueChangesFactory;
import "pipes/observable_pipe.dart" show ObservablePipeFactory;
import "pipes/promise_pipe.dart" show PromisePipeFactory;
import "pipes/uppercase_pipe.dart" show UpperCaseFactory;
import "pipes/lowercase_pipe.dart" show LowerCaseFactory;
import "pipes/json_pipe.dart" show JsonPipeFactory;
import "pipes/null_pipe.dart" show NullPipeFactory;
import "interfaces.dart"
    show ChangeDetection, ProtoChangeDetector, ChangeDetectorDefinition;
import "package:angular2/src/di/decorators.dart" show Injectable;
import "package:angular2/src/facade/collection.dart"
    show List, StringMapWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent, BaseException;

/**
 * Structural diffing for `Object`s and `Map`s.
 *
 * @exportedAs angular2/pipes
 */
List<PipeFactory> keyValDiff = [
  new KeyValueChangesFactory(),
  new NullPipeFactory()
];
/**
 * Structural diffing for `Iterable` types such as `Array`s.
 *
 * @exportedAs angular2/pipes
 */
List<PipeFactory> iterableDiff = [
  new IterableChangesFactory(),
  new NullPipeFactory()
];
/**
 * Async binding to such types as Observable.
 *
 * @exportedAs angular2/pipes
 */
List<PipeFactory> async = [
  new ObservablePipeFactory(),
  new PromisePipeFactory(),
  new NullPipeFactory()
];
/**
 * Uppercase text transform.
 *
 * @exportedAs angular2/pipes
 */
List<PipeFactory> uppercase = [new UpperCaseFactory(), new NullPipeFactory()];
/**
 * Lowercase text transform.
 *
 * @exportedAs angular2/pipes
 */
List<PipeFactory> lowercase = [new LowerCaseFactory(), new NullPipeFactory()];
/**
 * Json stringify transform.
 *
 * @exportedAs angular2/pipes
 */
List<PipeFactory> json = [new JsonPipeFactory(), new NullPipeFactory()];
var defaultPipes = {
  "iterableDiff": iterableDiff,
  "keyValDiff": keyValDiff,
  "async": async,
  "uppercase": uppercase,
  "lowercase": lowercase,
  "json": json
};
var preGeneratedProtoDetectors = {};
/**
 * Implements change detection using a map of pregenerated proto detectors.
 *
 * @exportedAs angular2/change_detection
 */
class PreGeneratedChangeDetection extends ChangeDetection {
  PipeRegistry registry;
  ChangeDetection _dynamicChangeDetection;
  Map<String, Function> _protoChangeDetectorFactories;
  PreGeneratedChangeDetection(this.registry, [protoChangeDetectors]) : super() {
    /* super call moved to initializer */;
    this._dynamicChangeDetection = new DynamicChangeDetection(registry);
    this._protoChangeDetectorFactories = isPresent(protoChangeDetectors)
        ? protoChangeDetectors
        : preGeneratedProtoDetectors;
  }
  ProtoChangeDetector createProtoChangeDetector(
      ChangeDetectorDefinition definition) {
    var id = definition.id;
    if (StringMapWrapper.contains(this._protoChangeDetectorFactories, id)) {
      return StringMapWrapper.get(this._protoChangeDetectorFactories, id)(
          this.registry);
    }
    return this._dynamicChangeDetection.createProtoChangeDetector(definition);
  }
}
/**
 * Implements change detection that does not require `eval()`.
 *
 * This is slower than {@link JitChangeDetection}.
 *
 * @exportedAs angular2/change_detection
 */
@Injectable()
class DynamicChangeDetection extends ChangeDetection {
  PipeRegistry registry;
  DynamicChangeDetection(this.registry) : super() {
    /* super call moved to initializer */;
  }
  ProtoChangeDetector createProtoChangeDetector(
      ChangeDetectorDefinition definition) {
    return new DynamicProtoChangeDetector(this.registry, definition);
  }
}
/**
 * Implements faster change detection, by generating source code.
 *
 * This requires `eval()`. For change detection that does not require `eval()`, see {@link
 *DynamicChangeDetection}.
 *
 * @exportedAs angular2/change_detection
 */
@Injectable()
class JitChangeDetection extends ChangeDetection {
  PipeRegistry registry;
  JitChangeDetection(this.registry) : super() {
    /* super call moved to initializer */;
  }
  ProtoChangeDetector createProtoChangeDetector(
      ChangeDetectorDefinition definition) {
    return new JitProtoChangeDetector(this.registry, definition);
  }
}
PipeRegistry defaultPipeRegistry = new PipeRegistry(defaultPipes);
