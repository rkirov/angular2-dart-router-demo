library angular2.src.render.dom.shadow_dom.style_inliner;

import "package:angular2/di.dart" show Injectable;
import "package:angular2/src/services/xhr.dart" show XHR;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "style_url_resolver.dart" show StyleUrlResolver;
import "package:angular2/src/facade/lang.dart"
    show
        isBlank,
        isPresent,
        RegExp,
        RegExpWrapper,
        StringWrapper,
        normalizeBlank;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;

/**
 * Inline @import rules in the given CSS.
 *
 * When an @import rules is inlined, it's url are rewritten.
 */
@Injectable()
class StyleInliner {
  XHR _xhr;
  UrlResolver _urlResolver;
  StyleUrlResolver _styleUrlResolver;
  StyleInliner(
      XHR xhr, StyleUrlResolver styleUrlResolver, UrlResolver urlResolver) {
    this._xhr = xhr;
    this._urlResolver = urlResolver;
    this._styleUrlResolver = styleUrlResolver;
  }
  /**
   * Inline the @imports rules in the given CSS text.
   *
   * The baseUrl is required to rewrite URLs in the inlined content.
   *
   * @param {string} cssText
   * @param {string} baseUrl
   * @returns {*} a Promise<string> when @import rules are present, a string otherwise
   */
  dynamic /* Future < String > | String */ inlineImports(
      String cssText, String baseUrl) {
    return this._inlineImports(cssText, baseUrl, []);
  }
  dynamic /* Future < String > | String */ _inlineImports(
      String cssText, String baseUrl, List<String> inlinedUrls) {
    var partIndex = 0;
    var parts = StringWrapper.split(cssText, _importRe);
    if (identical(parts.length, 1)) {
      // no @import rule found, return the original css
      return cssText;
    }
    var promises = [];
    while (partIndex < parts.length - 1) {
      // prefix is the content before the @import rule
      var prefix = parts[partIndex];
      // rule is the parameter of the @import rule
      var rule = parts[partIndex + 1];
      var url = _extractUrl(rule);
      if (isPresent(url)) {
        url = this._urlResolver.resolve(baseUrl, url);
      }
      var mediaQuery = _extractMediaQuery(rule);
      var promise;
      if (isBlank(url)) {
        promise = PromiseWrapper
            .resolve('''/* Invalid import rule: "@import ${ rule};" */''');
      } else if (ListWrapper.contains(inlinedUrls, url)) {
        // The current import rule has already been inlined, return the prefix only

        // Importing again might cause a circular dependency
        promise = PromiseWrapper.resolve(prefix);
      } else {
        ListWrapper.push(inlinedUrls, url);
        promise = PromiseWrapper.then(this._xhr.get(url), (rawCss) {
          // resolve nested @import rules
          var inlinedCss = this._inlineImports(rawCss, url, inlinedUrls);
          if (PromiseWrapper.isPromise(inlinedCss)) {
            // wait until nested @import are inlined
            return ((inlinedCss as Future<String>)).then((css) {
              return prefix +
                  this._transformImportedCss(css, mediaQuery, url) +
                  "\n";
            });
          } else {
            // there are no nested @import, return the css
            return prefix +
                this._transformImportedCss(
                    (inlinedCss as String), mediaQuery, url) +
                "\n";
          }
        }, (error) => '''/* failed to import ${ url} */
''');
      }
      ListWrapper.push(promises, promise);
      partIndex += 2;
    }
    return PromiseWrapper.all(promises).then((cssParts) {
      var cssText = cssParts.join("");
      if (partIndex < parts.length) {
        // append then content located after the last @import rule
        cssText += parts[partIndex];
      }
      return cssText;
    });
  }
  String _transformImportedCss(String css, String mediaQuery, String url) {
    css = this._styleUrlResolver.resolveUrls(css, url);
    return _wrapInMediaRule(css, mediaQuery);
  }
}
// Extracts the url from an import rule, supported formats:

// - 'url' / "url",

// - url(url) / url('url') / url("url")
String _extractUrl(String importRule) {
  var match = RegExpWrapper.firstMatch(_urlRe, importRule);
  if (isBlank(match)) return null;
  return isPresent(match[1]) ? match[1] : match[2];
}
// Extracts the media query from an import rule.

// Returns null when there is no media query.
String _extractMediaQuery(String importRule) {
  var match = RegExpWrapper.firstMatch(_mediaQueryRe, importRule);
  if (isBlank(match)) return null;
  var mediaQuery = match[1].trim();
  return (mediaQuery.length > 0) ? mediaQuery : null;
}
// Wraps the css in a media rule when the media query is not null
String _wrapInMediaRule(String css, String query) {
  return (isBlank(query))
      ? css
      : '''@media ${ query} {
${ css}
}''';
}
var _importRe = RegExpWrapper.create("@import\\s+([^;]+);");
var _urlRe = RegExpWrapper
    .create("url\\(\\s*?['\"]?([^'\")]+)['\"]?|" + "['\"]([^'\")]+)['\"]");
var _mediaQueryRe = RegExpWrapper.create("['\"][^'\"]+['\"]\\s*\\)?\\s*(.*)");
