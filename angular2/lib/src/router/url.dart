library angular2.src.router.url;

import "package:angular2/src/facade/lang.dart"
    show RegExpWrapper, StringWrapper;

var specialCharacters = [
  "/",
  ".",
  "*",
  "+",
  "?",
  "|",
  "(",
  ")",
  "[",
  "]",
  "{",
  "}",
  "\\"
];
var escapeRe =
    RegExpWrapper.create("(\\" + specialCharacters.join("|\\") + ")", "g");
String escapeRegex(String string) {
  return StringWrapper.replaceAllMapped(string, escapeRe, (match) {
    return "\\" + match;
  });
}
