library benchpress.src.webdriver.chrome_driver_extension;

import "package:angular2/di.dart" show bind;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, StringMapWrapper, Map;
import "package:angular2/src/facade/lang.dart"
    show
        Json,
        isPresent,
        isBlank,
        RegExpWrapper,
        StringWrapper,
        BaseException,
        NumberWrapper;
import "../web_driver_extension.dart" show WebDriverExtension, PerfLogFeatures;
import "../web_driver_adapter.dart" show WebDriverAdapter;
import "package:angular2/src/facade/async.dart" show Future;

class ChromeDriverExtension extends WebDriverExtension {
  // TODO(tbosch): use static values when our transpiler supports them
  static get BINDINGS {
    return _BINDINGS;
  }
  WebDriverAdapter _driver;
  ChromeDriverExtension(WebDriverAdapter driver) : super() {
    /* super call moved to initializer */;
    this._driver = driver;
  }
  gc() {
    return this._driver.executeScript("window.gc()");
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
  } // See [Chrome Trace Event Format](https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/edit)
  readPerfLog() {
    // TODO(tbosch): Bug in ChromeDriver: Need to execute at least one command
    // so that the browser logs can be read out!
    return this._driver
        .executeScript("1+1")
        .then((_) => this._driver.logs("performance"))
        .then((entries) {
      var events = [];
      ListWrapper.forEach(entries, (entry) {
        var message = Json.parse(entry["message"])["message"];
        if (StringWrapper.equals(message["method"], "Tracing.dataCollected")) {
          ListWrapper.push(events, message["params"]);
        }
        if (StringWrapper.equals(message["method"], "Tracing.bufferUsage")) {
          throw new BaseException(
              "The DevTools trace buffer filled during the test!");
        }
      });
      return this._convertPerfRecordsToEvents(events);
    });
  }
  _convertPerfRecordsToEvents(chromeEvents, [normalizedEvents = null]) {
    if (isBlank(normalizedEvents)) {
      normalizedEvents = [];
    }
    var majorGCPids = {};
    chromeEvents.forEach((event) {
      var cat = event["cat"];
      var name = event["name"];
      var args = event["args"];
      var pid = event["pid"];
      var ph = event["ph"];
      if (StringWrapper.equals(cat, "disabled-by-default-devtools.timeline")) {
        if (StringWrapper.equals(name, "FunctionCall") &&
            (isBlank(args) ||
                isBlank(args["data"]) ||
                !StringWrapper.equals(
                    args["data"]["scriptName"], "InjectedScript"))) {
          ListWrapper.push(
              normalizedEvents, normalizeEvent(event, {"name": "script"}));
        } else if (StringWrapper.equals(name, "RecalculateStyles") ||
            StringWrapper.equals(name, "Layout") ||
            StringWrapper.equals(name, "UpdateLayerTree") ||
            StringWrapper.equals(name, "Paint") ||
            StringWrapper.equals(name, "Rasterize") ||
            StringWrapper.equals(name, "CompositeLayers")) {
          ListWrapper.push(
              normalizedEvents, normalizeEvent(event, {"name": "render"}));
        } else if (StringWrapper.equals(name, "GCEvent")) {
          var normArgs = {
            "usedHeapSize": isPresent(args["usedHeapSizeAfter"])
                ? args["usedHeapSizeAfter"]
                : args["usedHeapSizeBefore"]
          };
          if (StringWrapper.equals(event["ph"], "E")) {
            normArgs["majorGc"] =
                isPresent(majorGCPids[pid]) && majorGCPids[pid];
          }
          majorGCPids[pid] = false;
          ListWrapper.push(normalizedEvents,
              normalizeEvent(event, {"name": "gc", "args": normArgs}));
        }
      } else if (StringWrapper.equals(cat, "blink.console")) {
        ListWrapper.push(
            normalizedEvents, normalizeEvent(event, {"name": name}));
      } else if (StringWrapper.equals(cat, "v8")) {
        if (StringWrapper.equals(name, "majorGC")) {
          if (StringWrapper.equals(ph, "B")) {
            majorGCPids[pid] = true;
          }
        }
      }
    });
    return normalizedEvents;
  }
  PerfLogFeatures perfLogFeatures() {
    return new PerfLogFeatures(render: true, gc: true);
  }
  bool supports(Map capabilities) {
    return StringWrapper.equals(
        capabilities["browserName"].toLowerCase(), "chrome");
  }
}
normalizeEvent(chromeEvent, data) {
  var ph = chromeEvent["ph"];
  if (StringWrapper.equals(ph, "S")) {
    ph = "b";
  } else if (StringWrapper.equals(ph, "F")) {
    ph = "e";
  }
  var result = {
    "pid": chromeEvent["pid"],
    "ph": ph,
    "cat": "timeline",
    "ts": chromeEvent["ts"] / 1000
  };
  if (identical(chromeEvent["ph"], "X")) {
    var dur = chromeEvent["dur"];
    if (isBlank(dur)) {
      dur = chromeEvent["tdur"];
    }
    result["dur"] = isBlank(dur) ? 0.0 : dur / 1000;
  }
  StringMapWrapper.forEach(data, (value, prop) {
    result[prop] = value;
  });
  return result;
}
var _BINDINGS = [
  bind(ChromeDriverExtension).toFactory(
      (driver) => new ChromeDriverExtension(driver), [WebDriverAdapter])
];
