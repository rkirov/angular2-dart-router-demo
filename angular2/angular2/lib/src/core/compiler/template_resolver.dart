library angular2.src.core.compiler.template_resolver;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/facade/lang.dart"
    show Type, stringify, isBlank, BaseException;
import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, List, ListWrapper;
import "package:angular2/src/reflection/reflection.dart" show reflector;

@Injectable()
class TemplateResolver {
  Map _cache;
  TemplateResolver() {
    this._cache = MapWrapper.create();
  }
  View resolve(Type component) {
    var view = MapWrapper.get(this._cache, component);
    if (isBlank(view)) {
      view = this._resolve(component);
      MapWrapper.set(this._cache, component, view);
    }
    return view;
  }
  _resolve(Type component) {
    var annotations = reflector.annotations(component);
    for (var i = 0; i < annotations.length; i++) {
      var annotation = annotations[i];
      if (annotation is View) {
        return annotation;
      }
    } // No annotation = dynamic component!
    return null;
  }
}
