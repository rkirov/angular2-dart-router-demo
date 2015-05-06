library benchpress.src.web_driver_adapter;

import "package:angular2/di.dart" show bind;
import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/src/facade/lang.dart" show BaseException, ABSTRACT;
import "package:angular2/src/facade/collection.dart"
    show
        List,
        Map; /**
 * A WebDriverAdapter bridges API differences between different WebDriver clients,
 * e.g. JS vs Dart Async vs Dart Sync webdriver.
 * Needs one implementation for every supported WebDriver client.
 */

@ABSTRACT()
abstract class WebDriverAdapter {
  static bindTo(delegateToken) {
    return [
      bind(WebDriverAdapter).toFactory((delegate) => delegate, [delegateToken])
    ];
  }
  Future waitFor(Function callback) {
    throw new BaseException("NYI");
  }
  Future executeScript(String script) {
    throw new BaseException("NYI");
  }
  Future<Map> capabilities() {
    throw new BaseException("NYI");
  }
  Future<List> logs(String type) {
    throw new BaseException("NYI");
  }
}
