library angular2.src.di.exceptions;

import "package:angular2/src/facade/collection.dart" show ListWrapper, List;
import "package:angular2/src/facade/lang.dart" show stringify;

List findFirstClosedCycle(List keys) {
  var res = [];
  for (var i = 0; i < keys.length; ++i) {
    if (ListWrapper.contains(res, keys[i])) {
      ListWrapper.push(res, keys[i]);
      return res;
    } else {
      ListWrapper.push(res, keys[i]);
    }
  }
  return res;
}
String constructResolvingPath(List keys) {
  if (keys.length > 1) {
    var reversed = findFirstClosedCycle(ListWrapper.reversed(keys));
    var tokenStrs = ListWrapper.map(reversed, (k) => stringify(k.token));
    return " (" + tokenStrs.join(" -> ") + ")";
  } else {
    return "";
  }
} /**
 * Base class for all errors arising from misconfigured bindings.
 *
 * @exportedAs angular2/di_errors
 */
class AbstractBindingError extends Error {
  List keys;
  Function constructResolvingMessage;
  var message; // TODO(tbosch): Can't do key:Key as this results in a circular dependency!
  AbstractBindingError(key, Function constructResolvingMessage) : super() {
    /* super call moved to initializer */;
    this.keys = [key];
    this.constructResolvingMessage = constructResolvingMessage;
    this.message = this.constructResolvingMessage(this.keys);
  } // TODO(tbosch): Can't do key:Key as this results in a circular dependency!
  void addKey(key) {
    ListWrapper.push(this.keys, key);
    this.message = this.constructResolvingMessage(this.keys);
  }
  String toString() {
    return this.message;
  }
} /**
 * Thrown when trying to retrieve a dependency by `Key` from {@link Injector}, but the {@link Injector} does not have a
 * {@link Binding} for {@link Key}.
 *
 * @exportedAs angular2/di_errors
 */
class NoBindingError extends AbstractBindingError {
  // TODO(tbosch): Can't do key:Key as this results in a circular dependency!
  NoBindingError(key) : super(key, (List keys) {
        var first = stringify(ListWrapper.first(keys).token);
        return '''No provider for ${ first}!${ constructResolvingPath ( keys )}''';
      }) {
    /* super call moved to initializer */;
  }
} /**
 * Thrown when trying to retrieve an async {@link Binding} using the sync API.
 *
 * ## Example
 *
 * ```javascript
 * var injector = Injector.resolveAndCreate([
 *   bind(Number).toAsyncFactory(() => {
 *     return new Promise((resolve) => resolve(1 + 2));
 *   }),
 *   bind(String).toFactory((v) => { return "Value: " + v; }, [String])
 * ]);
 *
 * injector.asyncGet(String).then((v) => expect(v).toBe('Value: 3'));
 * expect(() => {
 *   injector.get(String);
 * }).toThrowError(AsycBindingError);
 * ```
 *
 * The above example throws because `String` depends on `Number` which is async. If any binding in the dependency
 * graph is async then the graph can only be retrieved using the `asyncGet` API.
 *
 * @exportedAs angular2/di_errors
 */
class AsyncBindingError extends AbstractBindingError {
  // TODO(tbosch): Can't do key:Key as this results in a circular dependency!
  AsyncBindingError(key) : super(key, (List keys) {
        var first = stringify(ListWrapper.first(keys).token);
        return '''Cannot instantiate ${ first} synchronously. ''' +
            '''It is provided as a promise!${ constructResolvingPath ( keys )}''';
      }) {
    /* super call moved to initializer */;
  }
} /**
 * Thrown when dependencies form a cycle.
 *
 * ## Example:
 *
 * ```javascript
 * class A {
 *   constructor(b:B) {}
 * }
 * class B {
 *   constructor(a:A) {}
 * }
 * ```
 *
 * Retrieving `A` or `B` throws a `CyclicDependencyError` as the graph above cannot be constructed.
 *
 * @exportedAs angular2/di_errors
 */
class CyclicDependencyError extends AbstractBindingError {
  // TODO(tbosch): Can't do key:Key as this results in a circular dependency!
  CyclicDependencyError(key) : super(key, (List keys) {
        return '''Cannot instantiate cyclic dependency!${ constructResolvingPath ( keys )}''';
      }) {
    /* super call moved to initializer */;
  }
} /**
 * Thrown when a constructing type returns with an Error.
 *
 * The `InstantiationError` class contains the original error plus the dependency graph which caused this object to be
 * instantiated.
 *
 * @exportedAs angular2/di_errors
 */
class InstantiationError extends AbstractBindingError {
  var cause;
  var causeKey; // TODO(tbosch): Can't do key:Key as this results in a circular dependency!
  InstantiationError(cause, key) : super(key, (List keys) {
        var first = stringify(ListWrapper.first(keys).token);
        return '''Error during instantiation of ${ first}!${ constructResolvingPath ( keys )}.''' +
            ''' ORIGINAL ERROR: ${ cause}''';
      }) {
    /* super call moved to initializer */;
    this.cause = cause;
    this.causeKey = key;
  }
} /**
 * Thrown when an object other then {@link Binding} (or `Type`) is passed to {@link Injector} creation.
 *
 * @exportedAs angular2/di_errors
 */
class InvalidBindingError extends Error {
  String message;
  InvalidBindingError(binding) : super() {
    /* super call moved to initializer */;
    this.message =
        '''Invalid binding - only instances of Binding and Type are allowed, got: ${ binding}''';
  }
  String toString() {
    return this.message;
  }
} /**
 * Thrown when the class has no annotation information.
 *
 * Lack of annotation information prevents the {@link Injector} from determining which dependencies need to be injected into
 * the constructor.
 *
 * @exportedAs angular2/di_errors
 */
class NoAnnotationError extends Error {
  String message;
  NoAnnotationError(typeOrFunc) : super() {
    /* super call moved to initializer */;
    this.message =
        '''Cannot resolve all parameters for ${ stringify ( typeOrFunc )}.''' +
            ''' Make sure they all have valid type or annotations.''';
  }
  String toString() {
    return this.message;
  }
}
