library angular2.src.router.path_recognizer;

import "package:angular2/src/facade/lang.dart"
    show
        RegExp,
        RegExpWrapper,
        RegExpMatcherWrapper,
        StringWrapper,
        isPresent,
        isBlank,
        BaseException;
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
  generate(params) {
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
  generate(Map params) {
    if (!StringMapWrapper.contains(params, this.name)) {
      throw new BaseException(
          '''Route generator for \'${ this . name}\' was not included in parameters passed.''');
    }
    return StringMapWrapper.get(params, this.name);
  }
}
class StarSegment {
  String name;
  String regex;
  StarSegment(String name) {
    this.name = name;
    this.regex = "(.+)";
  }
  generate(Map params) {
    return StringMapWrapper.get(params, this.name);
  }
}
var paramMatcher = RegExpWrapper.create("^:([^/]+)\$");
var wildcardMatcher = RegExpWrapper.create("^\\*([^/]+)\$");
List parsePathString(String route) {
  // normalize route as not starting with a "/". Recognition will

  // also normalize.
  if (identical(route[0], "/")) {
    route = StringWrapper.substring(route, 1);
  }
  var segments = splitBySlash(route);
  var results = ListWrapper.create();
  for (var i = 0; i < segments.length; i++) {
    var segment = segments[i],
        match;
    if (isPresent(match = RegExpWrapper.firstMatch(paramMatcher, segment))) {
      ListWrapper.push(results, new DynamicSegment(match[1]));
    } else if (isPresent(
        match = RegExpWrapper.firstMatch(wildcardMatcher, segment))) {
      ListWrapper.push(results, new StarSegment(match[1]));
    } else if (segment.length > 0) {
      ListWrapper.push(results, new StaticSegment(segment));
    }
  }
  return results;
}
var SLASH_RE = RegExpWrapper.create("/");
List<String> splitBySlash(String url) {
  return StringWrapper.split(url, SLASH_RE);
}
// represents something like '/foo/:bar'
class PathRecognizer {
  List segments;
  RegExp regex;
  dynamic handler;
  PathRecognizer(String path, dynamic handler) {
    this.handler = handler;
    this.segments = ListWrapper.create();
    var segments = parsePathString(path);
    var regexString = "^";
    ListWrapper.forEach(segments, (segment) {
      regexString += "/" + segment.regex;
    });
    this.regex = RegExpWrapper.create(regexString);
    this.segments = segments;
  }
  Map parseParams(String url) {
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
  String generate(Map params) {
    return ListWrapper.join(ListWrapper.map(
        this.segments, (segment) => "/" + segment.generate(params)), "");
  }
}
