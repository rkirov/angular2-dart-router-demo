import 'package:angular2/angular2.dart';

@Component(
   selector: 'd' 
  )
@View(
  template: '<div>Hello {{name}}</div>'
)
class HomeComp {
    String name;
    HomeComp() : name = 'Friend' {}
}
