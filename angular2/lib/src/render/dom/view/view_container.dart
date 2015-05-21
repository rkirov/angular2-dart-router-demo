library angular2.src.render.dom.view.view_container;

import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, List;
import "view.dart" as viewModule;

class DomViewContainer {
  List<viewModule.DomView> views;
  DomViewContainer() {
    // The order in this list matches the DOM order.
    this.views = [];
  }
  contentTagContainers() {
    return this.views;
  }
  List<dynamic> nodes() {
    var r = [];
    for (var i = 0; i < this.views.length; ++i) {
      r = ListWrapper.concat(r, this.views[i].rootNodes);
    }
    return r;
  }
}
