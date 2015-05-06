library benchpress.src.reporter.json_file_reporter;

import "package:angular2/src/facade/lang.dart"
    show DateWrapper, isPresent, isBlank, Json;
import "package:angular2/src/facade/collection.dart" show List;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/di.dart" show bind, OpaqueToken;
import "../reporter.dart" show Reporter;
import "../sample_description.dart" show SampleDescription;
import "../measure_values.dart" show MeasureValues;
import "../common_options.dart"
    show Options; /**
 * A reporter that writes results into a json file.
 */

class JsonFileReporter extends Reporter {
  // TODO(tbosch): use static values when our transpiler supports them
  static get PATH {
    return _PATH;
  }
  static get BINDINGS {
    return _BINDINGS;
  }
  Function _writeFile;
  String _path;
  SampleDescription _description;
  Function _now;
  JsonFileReporter(sampleDescription, path, writeFile, now) : super() {
    /* super call moved to initializer */;
    this._description = sampleDescription;
    this._path = path;
    this._writeFile = writeFile;
    this._now = now;
  }
  Future reportMeasureValues(MeasureValues measureValues) {
    return PromiseWrapper.resolve(null);
  }
  Future reportSample(
      List<MeasureValues> completeSample, List<MeasureValues> validSample) {
    var content = Json.stringify({
      "description": this._description,
      "completeSample": completeSample,
      "validSample": validSample
    });
    var filePath =
        '''${ this . _path}/${ this . _description . id}_${ DateWrapper . toMillis ( this . _now ( ) )}.json''';
    return this._writeFile(filePath, content);
  }
}
var _PATH = new OpaqueToken("JsonFileReporter.path");
var _BINDINGS = [
  bind(JsonFileReporter).toFactory((sampleDescription, path, writeFile, now) =>
      new JsonFileReporter(sampleDescription, path, writeFile, now), [
    SampleDescription,
    _PATH,
    Options.WRITE_FILE,
    Options.NOW
  ]),
  bind(_PATH).toValue(".")
];
