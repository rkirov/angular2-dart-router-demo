library angular2.src.services.title;

import "package:angular2/src/dom/dom_adapter.dart" show DOM;

class Title {
  String getTitle() {
    return DOM.getTitle();
  }
  setTitle(String newTitle) {
    DOM.setTitle(newTitle);
  }
}
