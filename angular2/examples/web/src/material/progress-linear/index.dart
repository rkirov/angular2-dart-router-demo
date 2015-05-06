library examples.src.material.progress_linear.index;

import "package:angular2/angular2.dart" show bootstrap;
import "package:angular2_material/src/components/progress-linear/progress_linear.dart"
    show MdProgressLinear;
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
@View(templateUrl: "./demo_app.html", directives: const [MdProgressLinear])
class DemoApp {
  num progress;
  DemoApp() {
    this.progress = 40;
  }
  step(num s) {
    this.progress += s;
  }
}
main() {
  commonDemoSetup();
  bootstrap(DemoApp, [bind(UrlResolver).toValue(new DemoUrlResolver())]);
}
