library examples.src.material.demo_common;

import "package:angular2/src/facade/lang.dart" show IMPLEMENTS, print;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, RegExpWrapper, StringWrapper, BaseException;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;

void commonDemoSetup() {
  BrowserDomAdapter.makeCurrent();
  reflector.reflectionCapabilities = new ReflectionCapabilities();
}
@Injectable()
class DemoUrlResolver extends UrlResolver {
  static var a;
  bool isInPubServe;
  DemoUrlResolver() : super() {
    /* super call moved to initializer */;
    if (isBlank(UrlResolver.a)) {
      UrlResolver.a = DOM.createElement("a");
    }
    this.isInPubServe = _isInPubServe();
  }
  String resolve(String baseUrl, String url) {
    if (isBlank(baseUrl)) {
      DOM.resolveAndSetHref(UrlResolver.a, url, null);
      return DOM.getHref(UrlResolver.a);
    }
    if (isBlank(url) || url == "") return baseUrl;
    if (url[0] == "/") {
      throw new BaseException(
          '''Could not resolve the url ${ url} from ${ baseUrl}''');
    }
    var m = RegExpWrapper.firstMatch(_schemeRe, url);
    if (isPresent(m[1])) {
      return url;
    }
    if (StringWrapper.startsWith(url, "./")) {
      return '''${ baseUrl}/${ url}''';
    }
    if (this.isInPubServe) {
      return '''/packages/${ url}''';
    } else {
      return '''/${ url}''';
    }
  }
}
var _schemeRe = RegExpWrapper.create(
    "^([^:/?#]+:)?"); // TODO: remove this hack when http://dartbug.com/23128 is fixed
bool _isInPubServe() {
  try {
    int.parse("123");
    print(">> Running in Dart");
    return true;
  } catch (_) {
    print(">> Running in JS");
    return false;
  }
}
