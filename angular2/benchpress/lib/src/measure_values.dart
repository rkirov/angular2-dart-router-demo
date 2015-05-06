library benchpress.src.measure_values;

import "package:angular2/src/facade/lang.dart" show DateTime, DateWrapper;
import "package:angular2/src/facade/collection.dart" show Map;

class MeasureValues {
  DateTime timeStamp;
  num runIndex;
  Map values;
  MeasureValues(num runIndex, DateTime timeStamp, Map values) {
    this.timeStamp = timeStamp;
    this.runIndex = runIndex;
    this.values = values;
  }
  toJson() {
    return {
      "timeStamp": DateWrapper.toJson(this.timeStamp),
      "runIndex": this.runIndex,
      "values": this.values
    };
  }
}
