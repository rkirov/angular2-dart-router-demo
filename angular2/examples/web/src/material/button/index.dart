library examples.src.material.button.index;

import "package:angular2/angular2.dart"
    show bootstrap, MapWrapper, ListWrapper, For;
import "package:angular2_material/src/components/button/button.dart"
    show MdButton, MdAnchor;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "../demo_common.dart" show commonDemoSetup, DemoUrlResolver;
import "package:angular2/di.dart"
    show
        bind; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

@Component(selector: "demo-app")
@View(
    templateUrl: "./demo_app.html", directives: const [MdButton, MdAnchor, For])
class DemoApp {
  String previousClick;
  String action;
  num clickCount;
  List<num> items;
  DemoApp() {
    this.previousClick = "Nothing";
    this.action = "ACTIVATE";
    this.clickCount = 0;
    this.items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
  }
  click(String msg) {
    this.previousClick = msg;
  }
  submit(String msg, event) {
    event.preventDefault();
    this.previousClick = msg;
  }
  increment() {
    this.clickCount++;
  }
}
main() {
  commonDemoSetup();
  bootstrap(DemoApp, [bind(UrlResolver).toValue(new DemoUrlResolver())]);
}
