library examples.src.gestures.index;

import "package:angular2/angular2.dart" show bootstrap;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show
        ReflectionCapabilities; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

@Component(selector: "gestures-app")
@View(templateUrl: "template.html")
class GesturesCmp {
  String swipeDirection;
  num pinchScale;
  num rotateAngle;
  GesturesCmp() {
    this.swipeDirection = "-";
    this.pinchScale = 1;
    this.rotateAngle = 0;
  }
  onSwipe(event) {
    this.swipeDirection = event.deltaX > 0 ? "right" : "left";
  }
  onPinch(event) {
    this.pinchScale = event.scale;
  }
  onRotate(event) {
    this.rotateAngle = event.rotation;
  }
}
main() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  bootstrap(GesturesCmp);
}
