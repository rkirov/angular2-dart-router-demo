library angular2.src.core.testability.testability;

import "package:angular2/di.dart" show Injectable;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, List, ListWrapper;
import "package:angular2/src/facade/lang.dart"
    show StringWrapper, isBlank, BaseException;
import "get_testability.dart" as getTestabilityModule;

/**
 * The Testability service provides testing hooks that can be accessed from
 * the browser and by services such as Protractor. Each bootstrapped Angular
 * application on the page will have an instance of Testability.
 */
@Injectable()
class Testability {
  num _pendingCount;
  List<Function> _callbacks;
  Testability() {
    this._pendingCount = 0;
    this._callbacks = ListWrapper.create();
  }
  increaseCount([num delta = 1]) {
    this._pendingCount += delta;
    if (this._pendingCount < 0) {
      throw new BaseException("pending async requests below zero");
    } else if (this._pendingCount == 0) {
      this._runCallbacks();
    }
    return this._pendingCount;
  }
  _runCallbacks() {
    while (!identical(this._callbacks.length, 0)) {
      ListWrapper.removeLast(this._callbacks)();
    }
  }
  whenStable(Function callback) {
    ListWrapper.push(this._callbacks, callback);
    if (identical(this._pendingCount, 0)) {
      this._runCallbacks();
    }
  }
  num getPendingCount() {
    return this._pendingCount;
  }
  List<dynamic> findBindings(using, String binding, bool exactMatch) {
    // TODO(juliemr): implement.
    return [];
  }
}
@Injectable()
class TestabilityRegistry {
  Map<dynamic, Testability> _applications;
  TestabilityRegistry() {
    this._applications = MapWrapper.create();
    getTestabilityModule.GetTestability.addToWindow(this);
  }
  registerApplication(token, Testability testability) {
    MapWrapper.set(this._applications, token, testability);
  }
  Testability findTestabilityInTree(elem) {
    if (elem == null) {
      return null;
    }
    if (MapWrapper.contains(this._applications, elem)) {
      return MapWrapper.get(this._applications, elem);
    }
    if (DOM.isShadowRoot(elem)) {
      return this.findTestabilityInTree(DOM.getHost(elem));
    }
    return this.findTestabilityInTree(DOM.parentElement(elem));
  }
}
