library benchpress.src.sample_description;

import "package:angular2/src/facade/collection.dart"
    show StringMapWrapper, ListWrapper, Map;
import "package:angular2/di.dart" show bind, OpaqueToken;
import "validator.dart" show Validator;
import "metric.dart" show Metric;
import "common_options.dart"
    show
        Options; /**
 * SampleDescription merges all available descriptions about a sample
 */

class SampleDescription {
  // TODO(tbosch): use static values when our transpiler supports them
  static get BINDINGS {
    return _BINDINGS;
  }
  String id;
  Map description;
  Map metrics;
  SampleDescription(id, List<Map> descriptions, Map metrics) {
    this.id = id;
    this.metrics = metrics;
    this.description = {};
    ListWrapper.forEach(descriptions, (description) {
      StringMapWrapper.forEach(
          description, (value, prop) => this.description[prop] = value);
    });
  }
  toJson() {
    return {
      "id": this.id,
      "description": this.description,
      "metrics": this.metrics
    };
  }
}
var _BINDINGS = [
  bind(SampleDescription).toFactory((metric, id, forceGc, userAgent, validator,
      defaultDesc, userDesc) => new SampleDescription(id, [
    {"forceGc": forceGc, "userAgent": userAgent},
    validator.describe(),
    defaultDesc,
    userDesc
  ], metric.describe()), [
    Metric,
    Options.SAMPLE_ID,
    Options.FORCE_GC,
    Options.USER_AGENT,
    Validator,
    Options.DEFAULT_DESCRIPTION,
    Options.SAMPLE_DESCRIPTION
  ])
];
