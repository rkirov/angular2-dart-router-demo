library benchmarks.src.compiler.selector_benchmark;

import "package:angular2/src/render/dom/compiler/selector.dart"
    show SelectorMatcher;
import "package:angular2/src/render/dom/compiler/selector.dart"
    show CssSelector;
import "package:angular2/src/facade/lang.dart" show StringWrapper, Math;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, bindAction;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;

main() {
  BrowserDomAdapter.makeCurrent();
  var count = getIntParameter("selectors");
  var fixedMatcher;
  var fixedSelectorStrings = [];
  var fixedSelectors = [];
  for (var i = 0; i < count; i++) {
    ListWrapper.push(fixedSelectorStrings, randomSelector());
  }
  for (var i = 0; i < count; i++) {
    ListWrapper.push(
        fixedSelectors, CssSelector.parse(fixedSelectorStrings[i]));
  }
  fixedMatcher = new SelectorMatcher();
  for (var i = 0; i < count; i++) {
    fixedMatcher.addSelectables(fixedSelectors[i], i);
  }
  parse() {
    var result = [];
    for (var i = 0; i < count; i++) {
      ListWrapper.push(result, CssSelector.parse(fixedSelectorStrings[i]));
    }
    return result;
  }
  addSelectable() {
    var matcher = new SelectorMatcher();
    for (var i = 0; i < count; i++) {
      matcher.addSelectables(fixedSelectors[i], i);
    }
    return matcher;
  }
  match() {
    var matchCount = 0;
    for (var i = 0; i < count; i++) {
      fixedMatcher.match(fixedSelectors[i][0], (selector, selected) {
        matchCount += selected;
      });
    }
    return matchCount;
  }
  bindAction("#parse", parse);
  bindAction("#addSelectable", addSelectable);
  bindAction("#match", match);
}
randomSelector() {
  var res = randomStr(5);
  for (var i = 0; i < 3; i++) {
    res += "." + randomStr(5);
  }
  for (var i = 0; i < 3; i++) {
    res += "[" + randomStr(3) + "=" + randomStr(6) + "]";
  }
  return res;
}
randomStr(len) {
  var s = "";
  while (s.length < len) {
    s += randomChar();
  }
  return s;
}
randomChar() {
  var n = randomNum(62);
  if (n < 10) return n.toString();
  if (n < 36) return StringWrapper.fromCharCode(n + 55);
  return StringWrapper.fromCharCode(n + 61);
}
randomNum(max) {
  return Math.floor(Math.random() * max);
}
