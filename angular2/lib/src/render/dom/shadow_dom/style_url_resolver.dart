// Some of the code comes from WebComponents.JS

// https://github.com/webcomponents/webcomponentsjs/blob/master/src/HTMLImports/path.js
library angular2.src.render.dom.shadow_dom.style_url_resolver;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/lang.dart"
    show RegExp, RegExpWrapper, StringWrapper;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;

/**
 * Rewrites URLs by resolving '@import' and 'url()' URLs from the given base URL.
 */
@Injectable()
class StyleUrlResolver {
  UrlResolver _resolver;
  StyleUrlResolver(UrlResolver resolver) {
    this._resolver = resolver;
  }
  resolveUrls(String cssText, String baseUrl) {
    cssText = this._replaceUrls(cssText, _cssUrlRe, baseUrl);
    cssText = this._replaceUrls(cssText, _cssImportRe, baseUrl);
    return cssText;
  }
  _replaceUrls(String cssText, RegExp re, String baseUrl) {
    return StringWrapper.replaceAllMapped(cssText, re, (m) {
      var pre = m[1];
      var url = StringWrapper.replaceAll(m[2], _quoteRe, "");
      var post = m[3];
      var resolvedUrl = this._resolver.resolve(baseUrl, url);
      return pre + "'" + resolvedUrl + "'" + post;
    });
  }
}
var _cssUrlRe = RegExpWrapper.create("(url\\()([^)]*)(\\))");
var _cssImportRe =
    RegExpWrapper.create("(@import[\\s]+(?!url\\())['\"]([^'\"]*)['\"](.*;)");
var _quoteRe = RegExpWrapper.create("['\"]");
