library examples.src.material.grid_list.index;

import "package:angular2/angular2.dart" show bootstrap;
import "package:angular2_material/src/components/grid_list/grid_list.dart"
    show MdGridList, MdGridTile;
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
    templateUrl: "./demo_app.html", directives: const [MdGridList, MdGridTile])
class DemoApp {
  num tile3RowSpan;
  num tile3ColSpan;
  DemoApp() {
    this.tile3RowSpan = 3;
    this.tile3ColSpan = 3;
  }
}
main() {
  commonDemoSetup();
  bootstrap(DemoApp, [bind(UrlResolver).toValue(new DemoUrlResolver())]);
}
