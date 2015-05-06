library angular2.src.di.key;

import "package:angular2/src/facade/collection.dart" show MapWrapper;
import "package:angular2/src/facade/lang.dart"
    show
        stringify; // TODO: uncoment `int` once https://github.com/angular/angular/issues/1414 is fixed

/**
 * A unique object used for retrieving items from the {@link Injector}.
 *
 * Keys have:
 * - a system-wide unique `id`.
 * - a `token`, usually the `Type` of the instance.
 *
 * Keys are used internally by the {@link Injector} because their system-wide unique `id`s allow the
 * injector to index in arrays rather than looking up items in maps.
 *
 * @exportedAs angular2/di
 */
class Key {
  var token;
  var id;
  Key(token, id) {
    this.token = token;
    this.id = id;
  }
  get displayName {
    return stringify(this.token);
  } /**
   * Retrieves a `Key` for a token.
   */
  static Key get(token) {
    return _globalKeyRegistry.get(token);
  } /**
   * @returns the number of keys registered in the system.
   */
  static get numberOfKeys {
    return _globalKeyRegistry.numberOfKeys;
  }
} /**
 * @private
 */
class KeyRegistry {
  Map _allKeys;
  KeyRegistry() {
    this._allKeys = MapWrapper.create();
  }
  Key get(token) {
    if (token is Key) return token;
    if (MapWrapper.contains(this._allKeys, token)) {
      return MapWrapper.get(this._allKeys, token);
    }
    var newKey = new Key(token, Key.numberOfKeys);
    MapWrapper.set(this._allKeys, token, newKey);
    return newKey;
  }
  get numberOfKeys {
    return MapWrapper.size(this._allKeys);
  }
}
var _globalKeyRegistry = new KeyRegistry();
