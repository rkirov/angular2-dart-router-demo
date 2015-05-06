library angular2.src.reflection.reflector;

import "package:angular2/src/facade/lang.dart"
    show Type, isPresent, stringify, BaseException;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map, MapWrapper, StringMapWrapper;
import "types.dart" show SetterFn, GetterFn, MethodFn;
export "types.dart"
    show SetterFn, GetterFn, MethodFn; // HACK: workaround for Traceur behavior.

// It expects all transpiled modules to contain this marker.
// TODO: remove this when we no longer use traceur
var ___esModule = true;
class Reflector {
  Map<dynamic, dynamic> _typeInfo;
  Map<dynamic, dynamic> _getters;
  Map<dynamic, dynamic> _setters;
  Map<dynamic, dynamic> _methods;
  dynamic reflectionCapabilities;
  Reflector(reflectionCapabilities) {
    this._typeInfo = MapWrapper.create();
    this._getters = MapWrapper.create();
    this._setters = MapWrapper.create();
    this._methods = MapWrapper.create();
    this.reflectionCapabilities = reflectionCapabilities;
  }
  registerType(type, typeInfo) {
    MapWrapper.set(this._typeInfo, type, typeInfo);
  }
  registerGetters(getters) {
    _mergeMaps(this._getters, getters);
  }
  registerSetters(setters) {
    _mergeMaps(this._setters, setters);
  }
  registerMethods(methods) {
    _mergeMaps(this._methods, methods);
  }
  Function factory(Type type) {
    if (MapWrapper.contains(this._typeInfo, type)) {
      return MapWrapper.get(this._typeInfo, type)["factory"];
    } else {
      return this.reflectionCapabilities.factory(type);
    }
  }
  List<dynamic> parameters(typeOfFunc) {
    if (MapWrapper.contains(this._typeInfo, typeOfFunc)) {
      return MapWrapper.get(this._typeInfo, typeOfFunc)["parameters"];
    } else {
      return this.reflectionCapabilities.parameters(typeOfFunc);
    }
  }
  List<dynamic> annotations(typeOfFunc) {
    if (MapWrapper.contains(this._typeInfo, typeOfFunc)) {
      return MapWrapper.get(this._typeInfo, typeOfFunc)["annotations"];
    } else {
      return this.reflectionCapabilities.annotations(typeOfFunc);
    }
  }
  GetterFn getter(String name) {
    if (MapWrapper.contains(this._getters, name)) {
      return MapWrapper.get(this._getters, name);
    } else {
      return this.reflectionCapabilities.getter(name);
    }
  }
  SetterFn setter(String name) {
    if (MapWrapper.contains(this._setters, name)) {
      return MapWrapper.get(this._setters, name);
    } else {
      return this.reflectionCapabilities.setter(name);
    }
  }
  MethodFn method(String name) {
    if (MapWrapper.contains(this._methods, name)) {
      return MapWrapper.get(this._methods, name);
    } else {
      return this.reflectionCapabilities.method(name);
    }
  }
}
_mergeMaps(Map<dynamic, dynamic> target, config) {
  StringMapWrapper.forEach(config, (v, k) => MapWrapper.set(target, k, v));
}
