library angular2.src.render.dom.util;

import "package:angular2/src/facade/lang.dart"
    show StringWrapper, RegExpWrapper, isPresent;

const NG_BINDING_CLASS_SELECTOR = ".ng-binding";
const NG_BINDING_CLASS = "ng-binding";
const EVENT_TARGET_SEPARATOR = ":";
var CAMEL_CASE_REGEXP = RegExpWrapper.create("([A-Z])");
var DASH_CASE_REGEXP = RegExpWrapper.create("-([a-z])");
camelCaseToDashCase(String input) {
  return StringWrapper.replaceAllMapped(input, CAMEL_CASE_REGEXP, (m) {
    return "-" + m[1].toLowerCase();
  });
}
dashCaseToCamelCase(String input) {
  return StringWrapper.replaceAllMapped(input, DASH_CASE_REGEXP, (m) {
    return m[1].toUpperCase();
  });
}
