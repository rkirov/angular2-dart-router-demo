library angular2.src.router.path_recognizer;

import "package:angular2/src/facade/lang.dart"
    show
        RegExp,
        RegExpWrapper,
        RegExpMatcherWrapper,
        StringWrapper,
        isPresent,
        isBlank,
        BaseException,
        normalizeBlank;
import "package:angular2/src/facade/collection.dart"
    show Map, MapWrapper, Map, StringMapWrapper, List, ListWrapper;
import "url.dart" show escapeRegex;

class StaticSegment {
  String string;
  String regex;
  String name;
  StaticSegment(String string) {
    this.string = string;
    this.name = "";
    this.regex = escapeRegex(string);
  }
  String generate(params) {
    return this.string;
  }
}
class DynamicSegment {
  String name;
  String regex;
  DynamicSegment(String name) {
    this.name = name;
    this.regex = "([^/]+)";
  }
  String generate(Map<String, String> params) {
    if (!StringMapWrapper.contains(params, this.name)) {
      throw new BaseException(
          '''Route generator for \'${ this . name}\' was not included in parameters passed.''');
    }
    return normalizeBlank(StringMapWrapper.get(params, this.name));
  }
}
class StarSegment {
  String name;
  String regex;
  StarSegment(String name) {
    this.name = name;
    this.regex = "(.+)";
  }
  String generate(Map<String, String> params) {
    return normalizeBlank(StringMapWrapper.get(params, this.name));
  }
}
var paramMatcher = RegExpWrapper.create("^:([^/]+)\$");
var wildcardMatcher = RegExpWrapper.create("^\\*([^/]+)\$");
parsePathString(String route) {
  // normalize route as not starting with a "/". Recognition will

  // also normalize.
  if (identical(route[0], "/")) {
    route = StringWrapper.substring(route, 1);
  }
  var segments = splitBySlash(route);
  var results = ListWrapper.create();
  var specificity = 0;
  // The "specificity" of a path is used to determine which route is used when multiple routes match a URL.

  // Static segments (like "/foo") are the most specific, followed by dynamic segments (like "/:id"). Star segments

  // add no specificity. Segments at the start of the path are more specific than proceeding ones.

  // The code below uses place values to combine the different types of segments into a single integer that we can

  // sort later. Each static segment is worth hundreds of points of specificity (10000, 9900, ..., 200), and each

  // dynamic segment is worth single points of specificity (100, 99, ... 2).
  if (segments.length > 98) {
    throw new BaseException(
        '''\'${ route}\' has more than the maximum supported number of segments.''');
  }
  for (var i = 0; i < segments.length; i++) {
    var segment = segments[i],
        match;
    if (isPresent(match = RegExpWrapper.firstMatch(paramMatcher, segment))) {
      ListWrapper.push(results, new DynamicSegment(match[1]));
      specificity += (100 - i);
    } else if (isPresent(
        match = RegExpWrapper.firstMatch(wildcardMatcher, segment))) {
      ListWrapper.push(results, new StarSegment(match[1]));
    } else if (segment.length > 0) {
      ListWrapper.push(results, new StaticSegment(segment));
      specificity += 100 * (100 - i);
    }
  }
  return {"segments": results, "specificity": specificity};
}
List<String> splitBySlash(String url) {
  return url.split("/");
}
// represents something like '/foo/:bar'
class PathRecognizer {
  List segments;
  RegExp regex;
  dynamic handler;
  num specificity;
  String path;
  PathRecognizer(String path, dynamic handler) {
    this.path = path;
    this.handler = handler;
    this.segments = [];
    // TODO: use destructuring assignment

    // see https://github.com/angular/ts2dart/issues/158
    var parsed = parsePathString(path);
    var specificity = parsed["specificity"];
    var segments = parsed["segments"];
    var regexString = "^";
    ListWrapper.forEach(segments, (segment) {
      regexString += "/" + segment.regex;
    });
    this.regex = RegExpWrapper.create(regexString);
    this.segments = segments;
    this.specificity = specificity;
  }
  Map<String, String> parseParams(String url) {
    var params = StringMapWrapper.create();
    var urlPart = url;
    for (var i = 0; i < this.segments.length; i++) {
      var segment = this.segments[i];
      var match = RegExpWrapper.firstMatch(
          RegExpWrapper.create("/" + segment.regex), urlPart);
      urlPart = StringWrapper.substring(urlPart, match[0].length);
      if (segment.name.length > 0) {
        StringMapWrapper.set(params, segment.name, match[1]);
      }
    }
    return params;
  }
  String generate(Map<String, String> params) {
    return ListWrapper.join(ListWrapper.map(
        this.segments, (segment) => "/" + segment.generate(params)), "");
  }
}
