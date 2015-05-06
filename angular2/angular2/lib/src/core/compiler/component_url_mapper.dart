library angular2.src.core.compiler.component_url_mapper;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/lang.dart" show Type, isPresent;
import "package:angular2/src/facade/collection.dart" show Map, MapWrapper;

@Injectable()
class ComponentUrlMapper {
  // Returns the base URL to the component source file.
  // The returned URL could be:
  // - an absolute URL,
  // - a path relative to the application
  String getUrl(Type component) {
    return "./";
  }
}
class RuntimeComponentUrlMapper extends ComponentUrlMapper {
  Map _componentUrls;
  RuntimeComponentUrlMapper() : super() {
    /* super call moved to initializer */;
    this._componentUrls = MapWrapper.create();
  }
  setComponentUrl(Type component, String url) {
    MapWrapper.set(this._componentUrls, component, url);
  }
  String getUrl(Type component) {
    var url = MapWrapper.get(this._componentUrls, component);
    if (isPresent(url)) return url;
    return super.getUrl(component);
  }
}
