library benchmarks.src.change_detection.change_detection_benchmark;

import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/facade/lang.dart" show isPresent, isJsObject;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, bindAction, microBenchmark;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;
import "package:angular2/change_detection.dart"
    show
        Lexer,
        Parser,
        ChangeDispatcher,
        ChangeDetection,
        DynamicChangeDetection,
        JitChangeDetection,
        BindingRecord,
        DirectiveRecord,
        DirectiveIndex,
        DEFAULT; // ---- SHARED

class Obj {
  var field0;
  var field1;
  var field2;
  var field3;
  var field4;
  var field5;
  var field6;
  var field7;
  var field8;
  var field9;
  setField(index, value) {
    switch (index) {
      case 0:
        this.field0 = value;
        break;
      case 1:
        this.field1 = value;
        break;
      case 2:
        this.field2 = value;
        break;
      case 3:
        this.field3 = value;
        break;
      case 4:
        this.field4 = value;
        break;
      case 5:
        this.field5 = value;
        break;
      case 6:
        this.field6 = value;
        break;
      case 7:
        this.field7 = value;
        break;
      case 8:
        this.field8 = value;
        break;
      case 9:
        this.field9 = value;
        break;
    }
  }
  getField(index) {
    switch (index) {
      case 0:
        return this.field0;
      case 1:
        return this.field1;
      case 2:
        return this.field2;
      case 3:
        return this.field3;
      case 4:
        return this.field4;
      case 5:
        return this.field5;
      case 6:
        return this.field6;
      case 7:
        return this.field7;
      case 8:
        return this.field8;
      case 9:
        return this.field9;
    }
  }
}
class Row {
  var obj;
  var targetObj;
  var field0;
  var field1;
  var field2;
  var field3;
  var field4;
  var field5;
  var field6;
  var field7;
  var field8;
  var field9;
  var next;
}
createObject() {
  var obj = new Obj();
  for (var i = 0; i < 10; ++i) {
    obj.setField(i, i);
  }
  return obj;
}
changeObject(object) {
  for (var i = 0; i < 10; ++i) {
    object.setField(i, object.getField(i) + 1);
  }
}
setUpReflector() {
  reflector.registerGetters({
    "field0": (obj) {
      return obj.field0;
    },
    "field1": (obj) {
      return obj.field1;
    },
    "field2": (obj) {
      return obj.field2;
    },
    "field3": (obj) {
      return obj.field3;
    },
    "field4": (obj) {
      return obj.field4;
    },
    "field5": (obj) {
      return obj.field5;
    },
    "field6": (obj) {
      return obj.field6;
    },
    "field7": (obj) {
      return obj.field7;
    },
    "field8": (obj) {
      return obj.field8;
    },
    "field9": (obj) {
      return obj.field9;
    }
  });
  reflector.registerSetters({
    "field0": (obj, v) {
      return obj.field0 = v;
    },
    "field1": (obj, v) {
      return obj.field1 = v;
    },
    "field2": (obj, v) {
      return obj.field2 = v;
    },
    "field3": (obj, v) {
      return obj.field3 = v;
    },
    "field4": (obj, v) {
      return obj.field4 = v;
    },
    "field5": (obj, v) {
      return obj.field5 = v;
    },
    "field6": (obj, v) {
      return obj.field6 = v;
    },
    "field7": (obj, v) {
      return obj.field7 = v;
    },
    "field8": (obj, v) {
      return obj.field8 = v;
    },
    "field9": (obj, v) {
      return obj.field9 = v;
    }
  });
} // ---- BASELINE
setUpBaseline(iterations, object) {
  createRow(i) {
    var r = new Row();
    r.obj = object;
    r.targetObj = new Obj();
    return r;
  }
  var head = createRow(0);
  var current = head;
  for (var i = 1; i < iterations; i++) {
    var newRow = createRow(i);
    current.next = newRow;
    current = newRow;
  }
  return head;
}
checkBaselineRow(r) {
  var obj = r.obj;
  if (!identical(obj.field0, r.field0)) {
    r.field0 = obj.field0;
    r.targetObj.field0 = obj.field0;
  }
  if (!identical(obj.field1, r.field1)) {
    r.field1 = obj.field1;
    r.targetObj.field1 = obj.field1;
  }
  if (!identical(obj.field2, r.field2)) {
    r.field2 = obj.field2;
    r.targetObj.field2 = obj.field2;
  }
  if (!identical(obj.field3, r.field3)) {
    r.field3 = obj.field3;
    r.targetObj.field3 = obj.field3;
  }
  if (!identical(obj.field4, r.field4)) {
    r.field4 = obj.field4;
    r.targetObj.field4 = obj.field4;
  }
  if (!identical(obj.field5, r.field5)) {
    r.field5 = obj.field5;
    r.targetObj.field5 = obj.field5;
  }
  if (!identical(obj.field6, r.field6)) {
    r.field6 = obj.field6;
    r.targetObj.field6 = obj.field6;
  }
  if (!identical(obj.field7, r.field7)) {
    r.field7 = obj.field7;
    r.targetObj.field7 = obj.field7;
  }
  if (!identical(obj.field8, r.field8)) {
    r.field8 = obj.field8;
    r.targetObj.field8 = obj.field8;
  }
  if (!identical(obj.field9, r.field9)) {
    r.field9 = obj.field9;
    r.targetObj.field9 = obj.field9;
  }
}
runBaselineChangeDetection(baselineHead) {
  var current = baselineHead;
  while (isPresent(current)) {
    checkBaselineRow(current);
    current = current.next;
  }
}
runBaselineReads(baselineHead, numberOfRuns) {
  for (var i = 0; i < numberOfRuns; ++i) {
    runBaselineChangeDetection(baselineHead);
  }
}
runBaselineWrites(baselineHead, numberOfRuns, object) {
  for (var i = 0; i < numberOfRuns; ++i) {
    changeObject(object);
    runBaselineChangeDetection(baselineHead);
  }
} // ---- CHANGE DETECTION
setUpChangeDetection(ChangeDetection changeDetection, iterations, object) {
  var dispatcher = new DummyDispatcher();
  var parser = new Parser(new Lexer());
  var parentProto =
      changeDetection.createProtoChangeDetector("parent", [], [], []);
  var parentCd = parentProto.instantiate(dispatcher);
  var directiveRecord =
      new DirectiveRecord(new DirectiveIndex(0, 0), false, false, DEFAULT);
  var bindings = [
    BindingRecord.createForDirective(parser.parseBinding("field0", null),
        "field0", reflector.setter("field0"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field1", null),
        "field1", reflector.setter("field1"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field2", null),
        "field2", reflector.setter("field2"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field3", null),
        "field3", reflector.setter("field3"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field4", null),
        "field4", reflector.setter("field4"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field5", null),
        "field5", reflector.setter("field5"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field6", null),
        "field6", reflector.setter("field6"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field7", null),
        "field7", reflector.setter("field7"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field8", null),
        "field8", reflector.setter("field8"), directiveRecord),
    BindingRecord.createForDirective(parser.parseBinding("field9", null),
        "field9", reflector.setter("field9"), directiveRecord)
  ];
  var proto = changeDetection.createProtoChangeDetector(
      "proto", bindings, [], [directiveRecord]);
  var targetObj = new Obj();
  for (var i = 0; i < iterations; ++i) {
    var cd = proto.instantiate(dispatcher);
    cd.hydrate(object, null, new FakeDirectives(targetObj));
    parentCd.addChild(cd);
  }
  return parentCd;
}
runChangeDetectionReads(changeDetector, numberOfRuns) {
  for (var i = 0; i < numberOfRuns; ++i) {
    changeDetector.detectChanges();
  }
}
runChangeDetectionWrites(changeDetector, numberOfRuns, object) {
  for (var i = 0; i < numberOfRuns; ++i) {
    changeObject(object);
    changeDetector.detectChanges();
  }
}
main() {
  BrowserDomAdapter.makeCurrent();
  var numberOfChecks = getIntParameter("numberOfChecks");
  var numberOfRuns = getIntParameter("iterations");
  var numberOfChecksPerDetector = 10;
  var numberOfDetectors =
      numberOfChecks / numberOfChecksPerDetector / numberOfRuns;
  setUpReflector();
  var object = createObject(); // -- BASELINE
  var baselineHead = setUpBaseline(numberOfDetectors, object);
  runBaselineReads(baselineHead, 1);
  bindAction("#baselineChangeDetectionReads", () => microBenchmark(
      "detectChangesAvg", numberOfRuns,
      () => runBaselineReads(baselineHead, numberOfRuns)));
  bindAction("#baselineChangeDetectionWrites", () => microBenchmark(
      "detectChangesAvg", numberOfRuns, () =>
          runBaselineWrites(baselineHead, numberOfRuns, object))); // -- DYNAMIC
  var ng2DynamicChangeDetector = setUpChangeDetection(
      new DynamicChangeDetection(null), numberOfDetectors, object);
  runChangeDetectionReads(ng2DynamicChangeDetector, 1);
  bindAction("#ng2ChangeDetectionDynamicReads", () => microBenchmark(
      "detectChangesAvg", numberOfRuns,
      () => runChangeDetectionReads(ng2DynamicChangeDetector, numberOfRuns)));
  bindAction("#ng2ChangeDetectionDynamicWrites", () => microBenchmark(
      "detectChangesAvg", numberOfRuns, () => runChangeDetectionWrites(
          ng2DynamicChangeDetector, numberOfRuns, object))); // -- JIT
  // Reenable when we have transformers for Dart
  if (isJsObject({})) {
    var ng2JitChangeDetector = setUpChangeDetection(
        new JitChangeDetection(null), numberOfDetectors, object);
    runChangeDetectionReads(ng2JitChangeDetector, 1);
    bindAction("#ng2ChangeDetectionJitReads", () => microBenchmark(
        "detectChangesAvg", numberOfRuns,
        () => runChangeDetectionReads(ng2JitChangeDetector, numberOfRuns)));
    bindAction("#ng2ChangeDetectionJitWrites", () => microBenchmark(
        "detectChangesAvg", numberOfRuns, () => runChangeDetectionWrites(
            ng2JitChangeDetector, numberOfRuns, object)));
  } else {
    bindAction("#ng2ChangeDetectionJitReads", () {});
    bindAction("#ng2ChangeDetectionJitWrites", () {});
  }
}
class FakeDirectives {
  Obj targetObj;
  FakeDirectives(targetObj) {
    this.targetObj = targetObj;
  }
  getDirectiveFor(record) {
    return this.targetObj;
  }
}
class DummyDispatcher extends ChangeDispatcher {
  notifyOnBinding(bindingRecord, newValue) {
    throw "Should not be used";
  }
}