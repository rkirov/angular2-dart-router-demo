library angular2.src.router.route_recognizer;

import "package:angular2/src/facade/lang.dart"
    show RegExp, RegExpWrapper, StringWrapper, isPresent;
import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, List, ListWrapper, Map, StringMapWrapper;
import "path_recognizer.dart" show PathRecognizer;

class RouteRecognizer {
  Map<String, PathRecognizer> names;
  Map<String, String> redirects;
  Map<RegExp, PathRecognizer> matchers;
  RouteRecognizer() {
    this.names = MapWrapper.create();
    this.matchers = MapWrapper.create();
    this.redirects = MapWrapper.create();
  }
  addRedirect(String path, String target) {
    MapWrapper.set(this.redirects, path, target);
  }
  addConfig(String path, dynamic handler, [String alias = null]) {
    var recognizer = new PathRecognizer(path, handler);
    MapWrapper.set(this.matchers, recognizer.regex, recognizer);
    if (isPresent(alias)) {
      MapWrapper.set(this.names, alias, recognizer);
    }
  }
  List<Map> recognize(String url) {
    var solutions = [];
    MapWrapper.forEach(this.redirects, (target, path) {
      //TODO: "/" redirect case
      if (StringWrapper.startsWith(url, path)) {
        url = target + StringWrapper.substring(url, path.length);
      }
    });
    MapWrapper.forEach(this.matchers, (pathRecognizer, regex) {
      var match;
      if (isPresent(match = RegExpWrapper.firstMatch(regex, url))) {
        var solution = StringMapWrapper.create();
        StringMapWrapper.set(solution, "handler", pathRecognizer.handler);
        StringMapWrapper.set(solution, "params", pathRecognizer.parseParams(
            url)); //TODO(btford): determine a good generic way to deal with terminal matches
        if (url == "/") {
          StringMapWrapper.set(solution, "matchedUrl", "/");
          StringMapWrapper.set(solution, "unmatchedUrl", "");
        } else {
          StringMapWrapper.set(solution, "matchedUrl", match[0]);
          var unmatchedUrl = StringWrapper.substring(url, match[0].length);
          StringMapWrapper.set(solution, "unmatchedUrl", unmatchedUrl);
        }
        ListWrapper.push(solutions, solution);
      }
    });
    return solutions;
  }
  hasRoute(String name) {
    return MapWrapper.contains(this.names, name);
  }
  generate(String name, dynamic params) {
    var pathRecognizer = MapWrapper.get(this.names, name);
    return pathRecognizer.generate(params);
  }
}
