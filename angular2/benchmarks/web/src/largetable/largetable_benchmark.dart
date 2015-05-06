library benchmarks.src.largetable.largetable_benchmark;

import "package:angular2/angular2.dart"
    show
        bootstrap; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/life_cycle/life_cycle.dart" show LifeCycle;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/browser.dart" show window, document, gc;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, getStringParameter, bindAction;
import "package:angular2/directives.dart"
    show For, Switch, SwitchWhen, SwitchDefault;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:angular2/di.dart" show bind;
import "package:angular2/src/di/annotations_impl.dart" show Inject;

const BENCHMARK_TYPE = "LargetableComponent.benchmarkType";
const LARGETABLE_ROWS = "LargetableComponent.rows";
const LARGETABLE_COLS = "LargetableComponent.cols";
_createBindings() {
  return [
    bind(BENCHMARK_TYPE).toValue(getStringParameter("benchmarkType")),
    bind(LARGETABLE_ROWS).toValue(getIntParameter("rows")),
    bind(LARGETABLE_COLS).toValue(getIntParameter("columns"))
  ];
}
var BASELINE_LARGETABLE_TEMPLATE;
setupReflector() {
  reflector.reflectionCapabilities =
      new ReflectionCapabilities(); // TODO(kegluneq): Generate these.
  reflector.registerGetters({
    "benchmarktype": (o) => o.benchmarktype,
    "switch": (o) => null,
    "switchWhen": (o) => o.switchWhen
  });
  reflector.registerSetters({
    "benchmarktype": (o, v) => o.benchmarktype = v,
    "switch": (o, v) => null,
    "switchWhen": (o, v) => o.switchWhen = v
  });
}
main() {
  BrowserDomAdapter.makeCurrent();
  var totalRows = getIntParameter("rows");
  var totalColumns = getIntParameter("columns");
  BASELINE_LARGETABLE_TEMPLATE = DOM.createTemplate("<table></table>");
  setupReflector();
  var app;
  var lifecycle;
  var baselineRootLargetableComponent;
  ng2DestroyDom() {
    // TODO: We need an initial value as otherwise the getter for data.value will fail
    // --> this should be already caught in change detection!
    app.data = null;
    app.benchmarkType = "none";
    lifecycle.tick();
  }
  profile(create, destroy, name) {
    return () {
      window.console.profile(name + " w GC");
      var duration = 0;
      var count = 0;
      while (count++ < 150) {
        gc();
        var start = window.performance.now();
        create();
        duration += window.performance.now() - start;
        destroy();
      }
      window.console.profileEnd(name + " w GC");
      window.console.log(
          '''Iterations: ${ count}; time: ${ duration / count} ms / iteration''');
      window.console.profile(name + " w/o GC");
      duration = 0;
      count = 0;
      while (count++ < 150) {
        var start = window.performance.now();
        create();
        duration += window.performance.now() - start;
        destroy();
      }
      window.console.profileEnd(name + " w/o GC");
      window.console.log(
          '''Iterations: ${ count}; time: ${ duration / count} ms / iteration''');
    };
  }
  ng2CreateDom() {
    var data = ListWrapper.createFixedSize(totalRows);
    for (var i = 0; i < totalRows; i++) {
      data[i] = ListWrapper.createFixedSize(totalColumns);
      for (var j = 0; j < totalColumns; j++) {
        data[i][j] = new CellData(i, j);
      }
    }
    app.data = data;
    app.benchmarkType = getStringParameter("benchmarkType");
    lifecycle.tick();
  }
  noop() {}
  initNg2() {
    bootstrap(AppComponent, _createBindings()).then((ref) {
      var injector = ref.injector;
      app = injector.get(AppComponent);
      lifecycle = injector.get(LifeCycle);
      bindAction("#ng2DestroyDom", ng2DestroyDom);
      bindAction("#ng2CreateDom", ng2CreateDom);
      bindAction(
          "#ng2UpdateDomProfile", profile(ng2CreateDom, noop, "ng2-update"));
      bindAction("#ng2CreateDomProfile",
          profile(ng2CreateDom, ng2DestroyDom, "ng2-create"));
    });
  }
  baselineDestroyDom() {
    baselineRootLargetableComponent.update(buildTable(0, 0));
  }
  baselineCreateDom() {
    baselineRootLargetableComponent.update(buildTable(totalRows, totalColumns));
  }
  initBaseline() {
    baselineRootLargetableComponent = new BaseLineLargetableComponent(
        DOM.querySelector(document, "baseline"),
        getStringParameter("benchmarkType"), getIntParameter("rows"),
        getIntParameter("columns"));
    bindAction("#baselineDestroyDom", baselineDestroyDom);
    bindAction("#baselineCreateDom", baselineCreateDom);
    bindAction("#baselineUpdateDomProfile",
        profile(baselineCreateDom, noop, "baseline-update"));
    bindAction("#baselineCreateDomProfile",
        profile(baselineCreateDom, baselineDestroyDom, "baseline-create"));
  }
  initNg2();
  initBaseline();
}
buildTable(rows, columns) {
  var tbody = DOM.createElement("tbody");
  var template = DOM.createElement("span");
  var i, j, row, cell;
  DOM.appendChild(template, DOM.createElement("span"));
  DOM.appendChild(template, DOM.createTextNode(":"));
  DOM.appendChild(template, DOM.createElement("span"));
  DOM.appendChild(template, DOM.createTextNode("|"));
  for (i = 0; i < rows; i++) {
    row = DOM.createElement("div");
    DOM.appendChild(tbody, row);
    for (j = 0; j < columns; j++) {
      cell = DOM.clone(template);
      DOM.appendChild(row, cell);
      DOM.setText(cell.childNodes[0], i.toString());
      DOM.setText(cell.childNodes[2], j.toString());
    }
  }
  return tbody;
}
class BaseLineLargetableComponent {
  var element;
  var table;
  String benchmarkType;
  num rows;
  num columns;
  BaseLineLargetableComponent(element, benchmarkType, num rows, num columns) {
    this.element = element;
    this.benchmarkType = benchmarkType;
    this.rows = rows;
    this.columns = columns;
    this.table = DOM.clone(BASELINE_LARGETABLE_TEMPLATE.content.firstChild);
    var shadowRoot = DOM.createShadowRoot(this.element);
    DOM.appendChild(shadowRoot, this.table);
  }
  update(tbody) {
    var oldBody = DOM.querySelector(this.table, "tbody");
    if (oldBody != null) {
      DOM.replaceChild(this.table, tbody, oldBody);
    } else {
      DOM.appendChild(this.table, tbody);
    }
  }
}
class CellData {
  num i;
  num j;
  CellData(i, j) {
    this.i = i;
    this.j = j;
  }
  jFn() {
    return this.j;
  }
  iFn() {
    return this.i;
  }
}
@Component(selector: "app")
@View(
    directives: const [LargetableComponent],
    template: '''<largetable [data]=\'data\' [benchmarkType]=\'benchmarkType\'></largetable>''')
class AppComponent {
  var data;
  String benchmarkType;
}
@Component(
    selector: "largetable",
    properties: const {"data": "data", "benchmarkType": "benchmarktype"})
@View(directives: const [For, Switch, SwitchWhen, SwitchDefault], template: '''
      <table [switch]="benchmarkType">
        <tbody template="switch-when \'interpolation\'">
          <tr template="for #row of data">
            <td template="for #column of row">
              {{column.i}}:{{column.j}}|
            </td>
          </tr>
        </tbody>
        <tbody template="switch-when \'interpolationAttr\'">
          <tr template="for #row of data">
            <td template="for #column of row" i="{{column.i}}" j="{{column.j}}">
              i,j attrs
            </td>
          </tr>
        </tbody>
        <tbody template="switch-when \'interpolationFn\'">
          <tr template="for #row of data">
            <td template="for #column of row">
              {{column.iFn()}}:{{column.jFn()}}|
            </td>
          </tr>
        </tbody>
        <tbody template="switch-default">
          <tr>
            <td>
              <em>{{benchmarkType}} not yet implemented</em>
            </td>
          </tr>
        </tbody>
      </table>''')
class LargetableComponent {
  var data;
  String benchmarkType;
  num rows;
  num columns;
  LargetableComponent(@Inject(BENCHMARK_TYPE) benchmarkType,
      @Inject(LARGETABLE_ROWS) rows, @Inject(LARGETABLE_COLS) columns) {
    this.benchmarkType = benchmarkType;
    this.rows = rows;
    this.columns = columns;
  }
}
