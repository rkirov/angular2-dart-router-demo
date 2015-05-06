library benchmarks.src.naive_infinite_scroll.app;

import "package:angular2/src/facade/lang.dart" show int, isPresent;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, bindAction;
import "package:angular2/src/facade/async.dart" show PromiseWrapper;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "scroll_area.dart" show ScrollAreaComponent;
import "package:angular2/directives.dart" show If, For;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/browser.dart"
    show
        document; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

@Component(selector: "scroll-app")
@View(directives: const [ScrollAreaComponent, If, For], template: '''
  <div>
    <div style="display: flex">
      <scroll-area id="testArea"></scroll-area>
    </div>
    <div template="if scrollAreas.length > 0">
      <p>Following tables are only here to add weight to the UI:</p>
      <scroll-area template="for #scrollArea of scrollAreas"></scroll-area>
    </div>
  </div>''')
class App {
  List<int> scrollAreas;
  int iterationCount;
  int scrollIncrement;
  App() {
    var appSize = getIntParameter("appSize");
    this.iterationCount = getIntParameter("iterationCount");
    this.scrollIncrement = getIntParameter("scrollIncrement");
    appSize = appSize > 1 ? appSize - 1 : 0;
    this.scrollAreas = [];
    for (var i = 0; i < appSize; i++) {
      ListWrapper.push(this.scrollAreas, i);
    }
    bindAction("#run-btn", () {
      this.runBenchmark();
    });
    bindAction("#reset-btn", () {
      this._getScrollDiv().scrollTop = 0;
      var existingMarker = this._locateFinishedMarker();
      if (isPresent(existingMarker)) {
        DOM.removeChild(document.body, existingMarker);
      }
    });
  }
  runBenchmark() {
    var scrollDiv = this._getScrollDiv();
    int n = this.iterationCount;
    var scheduleScroll;
    scheduleScroll = () {
      PromiseWrapper.setTimeout(() {
        scrollDiv.scrollTop += this.scrollIncrement;
        n--;
        if (n > 0) {
          scheduleScroll();
        } else {
          this._scheduleFinishedMarker();
        }
      }, 0);
    };
    scheduleScroll();
  } // Puts a marker indicating that the test is finished.
  _scheduleFinishedMarker() {
    var existingMarker = this._locateFinishedMarker();
    if (isPresent(existingMarker)) {
      // Nothing to do, the marker is already there
      return;
    }
    PromiseWrapper.setTimeout(() {
      var finishedDiv = DOM.createElement("div");
      finishedDiv.id = "done";
      DOM.setInnerHTML(finishedDiv, "Finished");
      DOM.appendChild(document.body, finishedDiv);
    }, 0);
  }
  _locateFinishedMarker() {
    return DOM.querySelector(document.body, "#done");
  }
  _getScrollDiv() {
    return DOM.query("body /deep/ #testArea /deep/ #scrollDiv");
  }
}
