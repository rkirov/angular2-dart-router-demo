/// <reference path="../../typings/es6-promise/es6-promise.d.ts" />
library angular2.src.di.injector;

import "package:angular2/src/facade/collection.dart"
    show Map, List, MapWrapper, ListWrapper;
import "binding.dart" show ResolvedBinding, Binding, BindingBuilder, bind;
import "exceptions.dart"
    show
        AbstractBindingError,
        NoBindingError,
        AsyncBindingError,
        CyclicDependencyError,
        InstantiationError,
        InvalidBindingError;
import "package:angular2/src/facade/lang.dart"
    show FunctionWrapper, Type, isPresent, isBlank;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "key.dart" show Key;

var _constructing = new Object();
var _notFound = new Object();
class _Waiting {
  Future<dynamic> promise;
  _Waiting(Future<dynamic> promise) {
    this.promise = promise;
  }
}
bool _isWaiting(obj) {
  return obj is _Waiting;
}
/**
 * A dependency injection container used for resolving dependencies.
 *
 * An `Injector` is a replacement for a `new` operator, which can automatically resolve the
 * constructor dependencies.
 * In typical use, application code asks for the dependencies in the constructor and they are
 * resolved by the `Injector`.
 *
 * ## Example:
 *
 * Suppose that we want to inject an `Engine` into class `Car`, we would define it like this:
 *
 * ```javascript
 * class Engine {
 * }
 *
 * class Car {
 * 	constructor(@Inject(Engine) engine) {
 * 	}
 * }
 *
 * ```
 *
 * Next we need to write the code that creates and instantiates the `Injector`. We then ask for the
 * `root` object, `Car`, so that the `Injector` can recursively build all of that object's
 *dependencies.
 *
 * ```javascript
 * main() {
 *   var injector = Injector.resolveAndCreate([Car, Engine]);
 *
 *   // Get a reference to the `root` object, which will recursively instantiate the tree.
 *   var car = injector.get(Car);
 * }
 * ```
 * Notice that we don't use the `new` operator because we explicitly want to have the `Injector`
 * resolve all of the object's dependencies automatically.
 *
 * @exportedAs angular2/di
 */
class Injector {
  List<dynamic> _bindings;
  List<dynamic> _instances;
  Injector _parent;
  bool _defaultBindings;
  _AsyncInjectorStrategy _asyncStrategy;
  _SyncInjectorStrategy _syncStrategy;
  /**
   * Turns a list of binding definitions into an internal resolved list of resolved bindings.
   *
   * A resolution is a process of flattening multiple nested lists and converting individual
   * bindings into a list of {@link ResolvedBinding}s. The resolution can be cached by `resolve`
   * for the {@link Injector} for performance-sensitive code.
   *
   * @param `bindings` can be a list of `Type`, {@link Binding}, {@link ResolvedBinding}, or a
   * recursive list of more bindings.
   *
   * The returned list is sparse, indexed by `id` for the {@link Key}. It is generally not useful to
   *application code
   * other than for passing it to {@link Injector} functions that require resolved binding lists,
   *such as
   * `fromResolvedBindings` and `createChildFromResolved`.
   */
  static List<ResolvedBinding> resolve(List<dynamic> bindings) {
    var resolvedBindings = _resolveBindings(bindings);
    var flatten = _flattenBindings(resolvedBindings, MapWrapper.create());
    return _createListOfBindings(flatten);
  }
  /**
   * Resolves bindings and creates an injector based on those bindings. This function is slower than
   * the corresponding `fromResolvedBindings` because it needs to resolve bindings first. See
   *`resolve`
   * for the {@link Injector}.
   *
   * Prefer `fromResolvedBindings` in performance-critical code that creates lots of injectors.
   *
   * @param `bindings` can be a list of `Type`, {@link Binding}, {@link ResolvedBinding}, or a
   *recursive list of more
   * bindings.
   * @param `defaultBindings` Setting to true will auto-create bindings.
   */
  static Injector resolveAndCreate(List<dynamic> bindings,
      {defaultBindings: false}) {
    return new Injector(Injector.resolve(bindings), null, defaultBindings);
  }
  /**
   * Creates an injector from previously resolved bindings. This bypasses resolution and flattening.
   * This API is the recommended way to construct injectors in performance-sensitive parts.
   *
   * @param `bindings` A sparse list of {@link ResolvedBinding}s. See `resolve` for the {@link
   *Injector}.
   * @param `defaultBindings` Setting to true will auto-create bindings.
   */
  static Injector fromResolvedBindings(List<ResolvedBinding> bindings,
      {defaultBindings: false}) {
    return new Injector(bindings, null, defaultBindings);
  }
  /**
   * @param `bindings` A sparse list of {@link ResolvedBinding}s. See `resolve` for the {@link
   * Injector}.
   * @param `parent` Parent Injector or `null` if root Injector.
   * @param `defaultBindings` Setting to true will auto-create bindings. (Only use with root
   * injector.)
   */
  Injector(
      List<ResolvedBinding> bindings, Injector parent, bool defaultBindings) {
    this._bindings = bindings;
    this._instances = this._createInstances();
    this._parent = parent;
    this._defaultBindings = defaultBindings;
    this._asyncStrategy = new _AsyncInjectorStrategy(this);
    this._syncStrategy = new _SyncInjectorStrategy(this);
  }
  /**
   * Direct parent of this injector.
   */
  Injector get parent {
    return this._parent;
  }
  /**
   * Retrieves an instance from the injector.
   *
   * @param `token`: usually the `Type` of an object. (Same as the token used while setting up a
   *binding).
   * @returns an instance represented by the token. Throws if not found.
   */
  get(token) {
    return this._getByKey(Key.get(token), false, false, false);
  }
  /**
   * Retrieves an instance from the injector.
   *
   * @param `token`: usually a `Type`. (Same as the token used while setting up a binding).
   * @returns an instance represented by the token. Returns `null` if not found.
   */
  getOptional(token) {
    return this._getByKey(Key.get(token), false, false, true);
  }
  /**
   * Retrieves an instance from the injector asynchronously. Used with asynchronous bindings.
   *
   * @param `token`: usually a `Type`. (Same as token used while setting up a binding).
   * @returns a `Promise` which resolves to the instance represented by the token.
   */
  Future<dynamic> asyncGet(token) {
    return this._getByKey(Key.get(token), true, false, false);
  }
  /**
   * Creates a child injector and loads a new set of bindings into it.
   *
   * A resolution is a process of flattening multiple nested lists and converting individual
   * bindings into a list of {@link ResolvedBinding}s. The resolution can be cached by `resolve`
   * for the {@link Injector} for performance-sensitive code.
   *
   * @param `bindings` can be a list of `Type`, {@link Binding}, {@link ResolvedBinding}, or a
   * recursive list of more bindings.
   *
   */
  Injector resolveAndCreateChild(List<dynamic> bindings) {
    return new Injector(Injector.resolve(bindings), this, false);
  }
  /**
   * Creates a child injector and loads a new set of {@link ResolvedBinding}s into it.
   *
   * @param `bindings`: A sparse list of {@link ResolvedBinding}s.
   * See `resolve` for the {@link Injector}.
   * @returns a new child {@link Injector}.
   */
  Injector createChildFromResolved(List<ResolvedBinding> bindings) {
    return new Injector(bindings, this, false);
  }
  List<dynamic> _createInstances() {
    return ListWrapper.createFixedSize(Key.numberOfKeys + 1);
  }
  _getByKey(Key key, bool returnPromise, bool returnLazy, bool optional) {
    if (returnLazy) {
      return () => this._getByKey(key, returnPromise, false, optional);
    }
    var strategy = returnPromise ? this._asyncStrategy : this._syncStrategy;
    var instance = strategy.readFromCache(key);
    if (!identical(instance, _notFound)) return instance;
    instance = strategy.instantiate(key);
    if (!identical(instance, _notFound)) return instance;
    if (isPresent(this._parent)) {
      return this._parent._getByKey(key, returnPromise, returnLazy, optional);
    }
    if (optional) {
      return null;
    } else {
      throw new NoBindingError(key);
    }
  }
  List<dynamic> _resolveDependencies(
      Key key, ResolvedBinding binding, bool forceAsync) {
    try {
      var getDependency = (d) =>
          this._getByKey(d.key, forceAsync || d.asPromise, d.lazy, d.optional);
      return ListWrapper.map(binding.dependencies, getDependency);
    } catch (e) {
      this._clear(key);
      if (e is AbstractBindingError) e.addKey(key);
      throw e;
    }
  }
  _getInstance(Key key) {
    if (this._instances.length <= key.id) return null;
    return ListWrapper.get(this._instances, key.id);
  }
  void _setInstance(Key key, obj) {
    ListWrapper.set(this._instances, key.id, obj);
  }
  _getBinding(Key key) {
    var binding = this._bindings.length <= key.id
        ? null
        : ListWrapper.get(this._bindings, key.id);
    if (isBlank(binding) && this._defaultBindings) {
      dynamic token = key.token;
      return bind(key.token).toClass(token).resolve();
    } else {
      return binding;
    }
  }
  void _markAsConstructing(Key key) {
    this._setInstance(key, _constructing);
  }
  void _clear(Key key) {
    this._setInstance(key, null);
  }
}
class _SyncInjectorStrategy {
  Injector injector;
  _SyncInjectorStrategy(Injector injector) {
    this.injector = injector;
  }
  readFromCache(Key key) {
    if (identical(key.token, Injector)) {
      return this.injector;
    }
    var instance = this.injector._getInstance(key);
    if (identical(instance, _constructing)) {
      throw new CyclicDependencyError(key);
    } else if (isPresent(instance) && !_isWaiting(instance)) {
      return instance;
    } else {
      return _notFound;
    }
  }
  instantiate(Key key) {
    var binding = this.injector._getBinding(key);
    if (isBlank(binding)) return _notFound;
    if (binding.providedAsPromise) throw new AsyncBindingError(key);
    // add a marker so we can detect cyclic dependencies
    this.injector._markAsConstructing(key);
    var deps = this.injector._resolveDependencies(key, binding, false);
    return this._createInstance(key, binding, deps);
  }
  _createInstance(Key key, ResolvedBinding binding, List<dynamic> deps) {
    try {
      var instance = FunctionWrapper.apply(binding.factory, deps);
      this.injector._setInstance(key, instance);
      return instance;
    } catch (e) {
      this.injector._clear(key);
      throw new InstantiationError(e, key);
    }
  }
}
class _AsyncInjectorStrategy {
  Injector injector;
  _AsyncInjectorStrategy(Injector injector) {
    this.injector = injector;
  }
  readFromCache(Key key) {
    if (identical(key.token, Injector)) {
      return PromiseWrapper.resolve(this.injector);
    }
    var instance = this.injector._getInstance(key);
    if (identical(instance, _constructing)) {
      throw new CyclicDependencyError(key);
    } else if (_isWaiting(instance)) {
      return instance.promise;
    } else if (isPresent(instance)) {
      return PromiseWrapper.resolve(instance);
    } else {
      return _notFound;
    }
  }
  instantiate(Key key) {
    var binding = this.injector._getBinding(key);
    if (isBlank(binding)) return _notFound;
    // add a marker so we can detect cyclic dependencies
    this.injector._markAsConstructing(key);
    var deps = this.injector._resolveDependencies(key, binding, true);
    var depsPromise = PromiseWrapper.all(deps);
    var promise = PromiseWrapper
        .then(depsPromise, null, (e) => this._errorHandler(key, e))
        .then((deps) => this._findOrCreate(key, binding, deps))
        .then((instance) => this._cacheInstance(key, instance));
    this.injector._setInstance(key, new _Waiting(promise));
    return promise;
  }
  Future<dynamic> _errorHandler(Key key, e) {
    if (e is AbstractBindingError) e.addKey(key);
    return PromiseWrapper.reject(e);
  }
  _findOrCreate(Key key, ResolvedBinding binding, List<dynamic> deps) {
    try {
      var instance = this.injector._getInstance(key);
      if (!_isWaiting(instance)) return instance;
      return FunctionWrapper.apply(binding.factory, deps);
    } catch (e) {
      this.injector._clear(key);
      throw new InstantiationError(e, key);
    }
  }
  _cacheInstance(key, instance) {
    this.injector._setInstance(key, instance);
    return instance;
  }
}
List<ResolvedBinding> _resolveBindings(List<dynamic> bindings) {
  var resolvedList = ListWrapper.createFixedSize(bindings.length);
  for (var i = 0; i < bindings.length; i++) {
    var unresolved = bindings[i];
    var resolved;
    if (unresolved is ResolvedBinding) {
      resolved = unresolved;
    } else if (unresolved is Type) {
      resolved = bind(unresolved).toClass(unresolved).resolve();
    } else if (unresolved is Binding) {
      resolved = unresolved.resolve();
    } else if (unresolved is List) {
      resolved = _resolveBindings(unresolved);
    } else if (unresolved is BindingBuilder) {
      throw new InvalidBindingError(unresolved.token);
    } else {
      throw new InvalidBindingError(unresolved);
    }
    resolvedList[i] = resolved;
  }
  return resolvedList;
}
List<dynamic> _createListOfBindings(flattenedBindings) {
  var bindings = ListWrapper.createFixedSize(Key.numberOfKeys + 1);
  MapWrapper.forEach(flattenedBindings, (v, keyId) => bindings[keyId] = v);
  return bindings;
}
Map<num, ResolvedBinding> _flattenBindings(
    List<ResolvedBinding> bindings, Map<num, ResolvedBinding> res) {
  ListWrapper.forEach(bindings, (b) {
    if (b is ResolvedBinding) {
      MapWrapper.set(res, b.key.id, b);
    } else if (b is List) {
      _flattenBindings(b, res);
    }
  });
  return res;
}
