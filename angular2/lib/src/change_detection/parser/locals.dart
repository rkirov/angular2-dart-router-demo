library angular2.src.change_detection.parser.locals;

import "package:angular2/src/facade/lang.dart" show isPresent, BaseException;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper;

class Locals {
  Locals parent;
  Map<dynamic, dynamic> current;
  Locals(this.parent, this.current) {}
  bool contains(String name) {
    if (MapWrapper.contains(this.current, name)) {
      return true;
    }
    if (isPresent(this.parent)) {
      return this.parent.contains(name);
    }
    return false;
  }
  get(String name) {
    if (MapWrapper.contains(this.current, name)) {
      return MapWrapper.get(this.current, name);
    }
    if (isPresent(this.parent)) {
      return this.parent.get(name);
    }
    throw new BaseException('''Cannot find \'${ name}\'''');
  }
  void set(String name, value) {
    // TODO(rado): consider removing this check if we can guarantee this is not

    // exposed to the public API.

    // TODO: vsavkin maybe it should check only the local map
    if (MapWrapper.contains(this.current, name)) {
      MapWrapper.set(this.current, name, value);
    } else {
      throw new BaseException(
          "Setting of new keys post-construction is not supported.");
    }
  }
  void clearValues() {
    MapWrapper.clearValues(this.current);
  }
}
