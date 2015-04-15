import 'package:angular2/angular2.dart';

import 'package:angular2/src/reflection/reflection.dart' show reflector;
import 'package:angular2/src/reflection/reflection_capabilities.dart' show ReflectionCapabilities;
import 'package:hello_ng2/cmp.dart' show Test;

@Component(
    selector: 'hello-app',
    injectables: const [GreetingService])
@View(
    template: '''<div class=\"greeting\">{{greeting}} <span>world</span>!</div><test></test>''',
    directives: const [Test])
class HelloCmp {
  String greeting;
  HelloCmp(GreetingService service) {
    this.greeting = service.greeting;
  }
  changeGreeting() {
    this.greeting = 'howdy';
  }
}

class GreetingService {
  String greeting;
  GreetingService() {
    this.greeting = 'hello';
  }
}

main() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  bootstrap(HelloCmp);
}
