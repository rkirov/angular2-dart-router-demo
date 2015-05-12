library angular2.src.render.dom.compiler.template_loader;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/lang.dart"
    show isBlank, isPresent, BaseException, stringify;
import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, StringMapWrapper, Map;
import "package:angular2/src/facade/async.dart" show PromiseWrapper, Future;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/services/xhr.dart" show XHR;
import "../../api.dart" show ViewDefinition;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;

/**
 * Strategy to load component templates.
 * TODO: Make public API once we are more confident in this approach.
 */
@Injectable()
class TemplateLoader {
  XHR _xhr;
  Map _htmlCache;
  TemplateLoader(XHR xhr, UrlResolver urlResolver) {
    this._xhr = xhr;
    this._htmlCache = StringMapWrapper.create();
  }
  Future load(ViewDefinition template) {
    if (isPresent(template.template)) {
      return PromiseWrapper.resolve(DOM.createTemplate(template.template));
    }
    var url = template.absUrl;
    if (isPresent(url)) {
      var promise = StringMapWrapper.get(this._htmlCache, url);
      if (isBlank(promise)) {
        promise = this._xhr.get(url).then((html) {
          var template = DOM.createTemplate(html);
          return template;
        });
        StringMapWrapper.set(this._htmlCache, url, promise);
      }
      // We need to clone the result as others might change it

      // (e.g. the compiler).
      return promise.then((tplElement) => DOM.clone(tplElement));
    }
    throw new BaseException(
        "View should have either the url or template property set");
  }
}
