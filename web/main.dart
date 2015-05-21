import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:router_demo/components/home/home.dart';

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
  selector: 'bar'
)
@View(
  template: 'bar'
)
class BarCmp {}

@Component(
  selector: 'my-app'
)
@View(
  template: '<button (click)="go()">Go</button><router-outlet></router-outlet><a router-link="bar">link</a>',
  directives: const [RouterOutlet, RouterLink]
)
@RouteConfig(const [const {
  'path': '/',
  'component': HomeComp
},
const {
  'path': '/foo/:id',
  'component': FooCmp
},
const {
  'path': '/bar',
  'component': BarCmp,
  'as': 'bar'
}
])
class AppComp {
  Router r;
  AppComp(Router this.r);

  go() {
    r.navigate('/bar');
  }
}

main() {
  assert(false);
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  bootstrap(AppComp, routerInjectables);
}
