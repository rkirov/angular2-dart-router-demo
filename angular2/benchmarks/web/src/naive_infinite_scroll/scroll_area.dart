library benchmarks.src.naive_infinite_scroll.scroll_area;

import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper;
import "package:angular2/src/facade/math.dart"
    show
        Math; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "common.dart"
    show
        Offering,
        ITEMS,
        ITEM_HEIGHT,
        VISIBLE_ITEMS,
        VIEW_PORT_HEIGHT,
        ROW_WIDTH,
        HEIGHT;
import "random_data.dart" show generateOfferings;
import "scroll_item.dart" show ScrollItemComponent;
import "package:angular2/directives.dart" show For;

@Component(selector: "scroll-area")
@View(directives: const [ScrollItemComponent, For], template: '''
    <div>
        <div id="scrollDiv"
             [style]="scrollDivStyle"
             on-scroll="onScroll(\$event)">
            <div id="padding"></div>
            <div id="inner">
                <scroll-item
                    template="for #item of visibleItems"
                    [offering]="item">
                </scroll-item>
            </div>
        </div>
    </div>''')
class ScrollAreaComponent {
  List<Offering> _fullList;
  List<Offering> visibleItems;
  var scrollDivStyle;
  var paddingDiv;
  var innerDiv;
  ScrollAreaComponent() {
    this._fullList = generateOfferings(ITEMS);
    this.visibleItems = [];
    this.scrollDivStyle = MapWrapper.createFromPairs([
      ["height", '''${ VIEW_PORT_HEIGHT}px'''],
      ["width", "1000px"],
      ["border", "1px solid #000"],
      ["overflow", "scroll"]
    ]);
    this.onScroll(null);
  }
  onScroll(evt) {
    var scrollTop = 0;
    if (evt != null) {
      var scrollDiv = evt.target;
      if (this.paddingDiv == null) {
        this.paddingDiv = scrollDiv.querySelector("#padding");
      }
      if (this.innerDiv == null) {
        this.innerDiv = scrollDiv.querySelector("#inner");
        this.innerDiv.style.setProperty("width", '''${ ROW_WIDTH}px''');
      }
      scrollTop = scrollDiv.scrollTop;
    }
    var iStart = Math.floor(scrollTop / ITEM_HEIGHT);
    var iEnd = Math.min(iStart + VISIBLE_ITEMS + 1, this._fullList.length);
    var padding = iStart * ITEM_HEIGHT;
    if (this.innerDiv != null) {
      this.innerDiv.style.setProperty("height", '''${ HEIGHT - padding}px''');
    }
    if (this.paddingDiv != null) {
      this.paddingDiv.style.setProperty("height", '''${ padding}px''');
    }
    this.visibleItems = ListWrapper.slice(this._fullList, iStart, iEnd);
  }
}
