library examples.src.material.radio.index;

import "package:angular2/angular2.dart" show bootstrap;
import "package:angular2_material/src/components/radio/radio_button.dart"
    show MdRadioButton, MdRadioGroup;
import "package:angular2_material/src/components/radio/radio_dispatcher.dart"
    show MdRadioDispatcher;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "../demo_common.dart" show commonDemoSetup, DemoUrlResolver;
import "package:angular2/di.dart"
    show
        bind; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

@Component(selector: "demo-app", injectables: const [MdRadioDispatcher])
@View(
    templateUrl: "./demo_app.html",
    directives: const [MdRadioGroup, MdRadioButton])
class DemoApp {
  var thirdValue;
  var groupValueChangeCount;
  var individualValueChanges;
  var pokemon;
  var someTabindex;
  DemoApp() {
    this.thirdValue = "dr-who";
    this.groupValueChangeCount = 0;
    this.individualValueChanges = 0;
    this.pokemon = "";
    this.someTabindex = 888;
  }
  chooseCharmander() {
    this.pokemon = "fire";
  }
  onGroupChange() {
    this.groupValueChangeCount++;
  }
  onIndividualClick() {
    this.individualValueChanges++;
  }
}
main() {
  commonDemoSetup();
  bootstrap(DemoApp, [bind(UrlResolver).toValue(new DemoUrlResolver())]);
}
