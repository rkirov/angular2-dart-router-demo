library angular2.src.services.url_resolver;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, RegExpWrapper, BaseException;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;

@Injectable()
class UrlResolver {
  static var a;
  UrlResolver() {
    if (isBlank(UrlResolver.a)) {
      UrlResolver.a = DOM.createElement("a");
    }
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
    DOM.resolveAndSetHref(UrlResolver.a, baseUrl, url);
    return DOM.getHref(UrlResolver.a);
  }
}
var _schemeRe = RegExpWrapper.create("^([^:/?#]+:)?");
