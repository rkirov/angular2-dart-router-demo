library examples.src.hello_world.index_common;

import "package:angular2/angular2.dart" show ElementRef;
import "package:angular2/src/di/annotations_impl.dart"
    show
        Injectable; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart"
    show View; // Angular 2.0 supports 2 basic types of directives:

// - Component - the basic building blocks of Angular 2.0 apps. Backed by
//   ShadowDom.(http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom/)
// - Directive - add behavior to existing elements.
// @Component is AtScript syntax to annotate the HelloCmp class as an Angular
// 2.0 component.
@Component(selector: "hello-app", injectables: const [GreetingService])
@View(
    template: '''<div class="greeting">{{greeting}} <span red>world</span>!</div>
           <button class="changeButton" (click)="changeGreeting()">change greeting</button><content></content>''',
    directives: const [RedDec])
class HelloCmp {
  String greeting;
  HelloCmp(GreetingService service) {
    this.greeting = service.greeting;
  }
  changeGreeting() {
    this.greeting = "howdy";
  }
} // Directives are light-weight. They don't allow new
// expression contexts (use @Component for those needs).
@Directive(selector: "[red]")
class RedDec {
  // ElementRef is always injectable and it wraps the element on which the
  // directive was found by the compiler.
  RedDec(ElementRef el) {
    el.domElement.style.color = "red";
  }
} // A service available to the Injector, used by the HelloCmp component.
@Injectable()
class GreetingService {
  String greeting;
  GreetingService() {
    this.greeting = "hello";
  }
}
