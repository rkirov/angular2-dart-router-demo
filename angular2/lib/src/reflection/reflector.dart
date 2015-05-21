library angular2.src.reflection.reflector;

import "package:angular2/src/facade/lang.dart"
    show Type, isPresent, stringify, BaseException;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map, MapWrapper, StringMapWrapper;
import "types.dart" show SetterFn, GetterFn, MethodFn;
export "types.dart" show SetterFn, GetterFn, MethodFn;

class Reflector {
  Map<Type, dynamic> _typeInfo;
  Map<String, GetterFn> _getters;
  Map<String, SetterFn> _setters;
  Map<String, MethodFn> _methods;
  dynamic reflectionCapabilities;
  Reflector(reflectionCapabilities) {
    this._typeInfo = MapWrapper.create();
    this._getters = MapWrapper.create();
    this._setters = MapWrapper.create();
    this._methods = MapWrapper.create();
    this.reflectionCapabilities = reflectionCapabilities;
  }
  void registerType(Type type, Map<Type, dynamic> typeInfo) {
    MapWrapper.set(this._typeInfo, type, typeInfo);
  }
  void registerGetters(Map<String, GetterFn> getters) {
    _mergeMaps(this._getters, getters);
  }
  void registerSetters(Map<String, SetterFn> setters) {
    _mergeMaps(this._setters, setters);
  }
  void registerMethods(Map<String, MethodFn> methods) {
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
void _mergeMaps(Map<dynamic, dynamic> target, Map<String, Function> config) {
  StringMapWrapper.forEach(config, (v, k) => MapWrapper.set(target, k, v));
}
