library benchpress.src.webdriver.ios_driver_extension;

import "package:angular2/di.dart" show bind;
import "package:angular2/src/facade/collection.dart" show ListWrapper, Map;
import "package:angular2/src/facade/lang.dart"
    show Json, isPresent, isBlank, RegExpWrapper, StringWrapper, BaseException;
import "../web_driver_extension.dart" show WebDriverExtension, PerfLogFeatures;
import "../web_driver_adapter.dart" show WebDriverAdapter;
import "package:angular2/src/facade/async.dart" show Future;

class IOsDriverExtension extends WebDriverExtension {
  // TODO(tbosch): use static values when our transpiler supports them
  static get BINDINGS {
    return _BINDINGS;
  }
  WebDriverAdapter _driver;
  IOsDriverExtension(WebDriverAdapter driver) : super() {
    /* super call moved to initializer */;
    this._driver = driver;
  }
  gc() {
    throw new BaseException("Force GC is not supported on iOS");
  }
  Future timeBegin(String name) {
    return this._driver.executeScript('''console.time(\'${ name}\');''');
  }
  Future timeEnd(String name, [String restartName = null]) {
    var script = '''console.timeEnd(\'${ name}\');''';
    if (isPresent(restartName)) {
      script += '''console.time(\'${ restartName}\');''';
    }
    return this._driver.executeScript(script);
  } // See https://github.com/WebKit/webkit/tree/master/Source/WebInspectorUI/Versions
  readPerfLog() {
    // TODO(tbosch): Bug in IOsDriver: Need to execute at least one command
    // so that the browser logs can be read out!
    return this._driver
        .executeScript("1+1")
        .then((_) => this._driver.logs("performance"))
        .then((entries) {
      var records = [];
      ListWrapper.forEach(entries, (entry) {
        var message = Json.parse(entry["message"])["message"];
        if (StringWrapper.equals(message["method"], "Timeline.eventRecorded")) {
          ListWrapper.push(records, message["params"]["record"]);
        }
      });
      return this._convertPerfRecordsToEvents(records);
    });
  }
  _convertPerfRecordsToEvents(records, [events = null]) {
    if (isBlank(events)) {
      events = [];
    }
    records.forEach((record) {
      var endEvent = null;
      var type = record["type"];
      var data = record["data"];
      var startTime = record["startTime"];
      var endTime = record["endTime"];
      if (StringWrapper.equals(type, "FunctionCall") &&
          (isBlank(data) ||
              !StringWrapper.equals(data["scriptName"], "InjectedScript"))) {
        ListWrapper.push(events, createStartEvent("script", startTime));
        endEvent = createEndEvent("script", endTime);
      } else if (StringWrapper.equals(type, "Time")) {
        ListWrapper.push(
            events, createMarkStartEvent(data["message"], startTime));
      } else if (StringWrapper.equals(type, "TimeEnd")) {
        ListWrapper.push(
            events, createMarkEndEvent(data["message"], startTime));
      } else if (StringWrapper.equals(type, "RecalculateStyles") ||
          StringWrapper.equals(type, "Layout") ||
          StringWrapper.equals(type, "UpdateLayerTree") ||
          StringWrapper.equals(type, "Paint") ||
          StringWrapper.equals(type, "Rasterize") ||
          StringWrapper.equals(type, "CompositeLayers")) {
        ListWrapper.push(events, createStartEvent("render", startTime));
        endEvent = createEndEvent("render", endTime);
      } // Note: ios used to support GCEvent up until iOS 6 :-(
      if (isPresent(record["children"])) {
        this._convertPerfRecordsToEvents(record["children"], events);
      }
      if (isPresent(endEvent)) {
        ListWrapper.push(events, endEvent);
      }
    });
    return events;
  }
  PerfLogFeatures perfLogFeatures() {
    return new PerfLogFeatures(render: true);
  }
  bool supports(Map capabilities) {
    return StringWrapper.equals(
        capabilities["browserName"].toLowerCase(), "safari");
  }
}
createEvent(ph, name, time, [args = null]) {
  var result = {
    "cat": "timeline",
    "name": name,
    "ts": time,
    "ph":
        ph, // The ios protocol does not support the notions of multiple processes in
    // the perflog...
    "pid": "pid0"
  };
  if (isPresent(args)) {
    result["args"] = args;
  }
  return result;
}
createStartEvent(name, time, [args = null]) {
  return createEvent("B", name, time, args);
}
createEndEvent(name, time, [args = null]) {
  return createEvent("E", name, time, args);
}
createMarkStartEvent(name, time) {
  return createEvent("b", name, time);
}
createMarkEndEvent(name, time) {
  return createEvent("e", name, time);
}
var _BINDINGS = [
  bind(IOsDriverExtension).toFactory(
      (driver) => new IOsDriverExtension(driver), [WebDriverAdapter])
];
