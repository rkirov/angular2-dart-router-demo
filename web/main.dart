import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular2/di.dart' show bind;
import 'package:router_demo/components/home/home.dart';
import 'dart:html';

import 'package:angular2/src/reflection/reflection.dart' show reflector;
import 'package:angular2/src/reflection/reflection_capabilities.dart' show ReflectionCapabilities;

@Component(
  selector: 'foo'
)
@View(
  template: 'foo {{id}}'
)
class FooCmp {
  String id;
  FooCmp(RouteParams pr) {
    id = pr.get('id');
    print(id);
  }
}

@Component(
  selector: 'my-app'
)
@View(
  template: '<button (click)="go()">Go</button><router-outlet></router-outlet>',
  directives: const [RouterOutlet]
)
@RouteConfig(const [const {
  'path': '/',
  'component': HomeComp
},
const {
  'path': '/:id',
  'component': FooCmp
}
])
class AppComp {
  Router r;
  AppComp(Router r) {
    this.r = r;
  }
  go() {
    r.navigate('/3');
  }
}

main() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();

  bootstrap(AppComp, routerInjectables);
}
