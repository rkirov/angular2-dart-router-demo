library benchpress.src.web_driver_extension;

import "package:angular2/di.dart" show bind, Injector, OpaqueToken;
import "package:angular2/src/facade/lang.dart"
    show BaseException, ABSTRACT, isBlank, isPresent;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, Map;
import "common_options.dart"
    show
        Options; /**
 * A WebDriverExtension implements extended commands of the webdriver protocol
 * for a given browser, independent of the WebDriverAdapter.
 * Needs one implementation for every supported Browser.
 */

@ABSTRACT()
abstract class WebDriverExtension {
  static bindTo(childTokens) {
    return [
      bind(_CHILDREN)
          .toAsyncFactory((injector) => PromiseWrapper.all(ListWrapper.map(
              childTokens, (token) => injector.asyncGet(token))), [
        Injector
      ]),
      bind(WebDriverExtension).toFactory((children, capabilities) {
        var delegate;
        ListWrapper.forEach(children, (extension) {
          if (extension.supports(capabilities)) {
            delegate = extension;
          }
        });
        if (isBlank(delegate)) {
          throw new BaseException(
              "Could not find a delegate for given capabilities!");
        }
        return delegate;
      }, [_CHILDREN, Options.CAPABILITIES])
    ];
  }
  Future gc() {
    throw new BaseException("NYI");
  }
  Future timeBegin(name) {
    throw new BaseException("NYI");
  }
  Future timeEnd(name, bool restart) {
    throw new BaseException("NYI");
  } /**
   * Format:
   * - cat: category of the event
   * - name: event name: 'script', 'gc', 'render', ...
   * - ph: phase: 'B' (begin), 'E' (end), 'b' (nestable start), 'e' (nestable end), 'X' (Complete event)
   * - ts: timestamp in ms, e.g. 12345
   * - pid: process id
   * - args: arguments, e.g. {heapSize: 1234}
   *
   * Based on [Chrome Trace Event Format](https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/edit)
   **/
  Future<List> readPerfLog() {
    throw new BaseException("NYI");
  }
  PerfLogFeatures perfLogFeatures() {
    throw new BaseException("NYI");
  }
  bool supports(Map capabilities) {
    return true;
  }
}
class PerfLogFeatures {
  bool render;
  bool gc;
  PerfLogFeatures({render, gc}) {
    this.render = isPresent(render) && render;
    this.gc = isPresent(gc) && gc;
  }
}
var _CHILDREN = new OpaqueToken("WebDriverExtension.children");
