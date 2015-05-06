library angular2.src.dom.dom_adapter;

import "package:angular2/src/facade/lang.dart" show ABSTRACT, BaseException;

DomAdapter DOM;
setRootDomAdapter(DomAdapter adapter) {
  DOM = adapter;
}
_abstract() {
  return new BaseException("This method is abstract");
} /**
 * Provides DOM operations in an environment-agnostic way.
 */
@ABSTRACT()
abstract class DomAdapter {
  logError(error) {
    throw _abstract();
  } /**
   * Maps attribute names to their corresponding property names for cases
   * where attribute name doesn't match property name.
   */
  get attrToPropMap {
    throw _abstract();
  }
  parse(String templateHtml) {
    throw _abstract();
  }
  query(String selector) {
    throw _abstract();
  }
  querySelector(el, String selector) {
    throw _abstract();
  }
  List querySelectorAll(el, String selector) {
    throw _abstract();
  }
  on(el, evt, listener) {
    throw _abstract();
  }
  Function onAndCancel(el, evt, listener) {
    throw _abstract();
  }
  dispatchEvent(el, evt) {
    throw _abstract();
  }
  createMouseEvent(eventType) {
    throw _abstract();
  }
  createEvent(eventType) {
    throw _abstract();
  }
  getInnerHTML(el) {
    throw _abstract();
  }
  getOuterHTML(el) {
    throw _abstract();
  }
  String nodeName(node) {
    throw _abstract();
  }
  String nodeValue(node) {
    throw _abstract();
  }
  String type(node) {
    throw _abstract();
  }
  content(node) {
    throw _abstract();
  }
  firstChild(el) {
    throw _abstract();
  }
  nextSibling(el) {
    throw _abstract();
  }
  parentElement(el) {
    throw _abstract();
  }
  List childNodes(el) {
    throw _abstract();
  }
  List childNodesAsList(el) {
    throw _abstract();
  }
  clearNodes(el) {
    throw _abstract();
  }
  appendChild(el, node) {
    throw _abstract();
  }
  removeChild(el, node) {
    throw _abstract();
  }
  replaceChild(el, newNode, oldNode) {
    throw _abstract();
  }
  remove(el) {
    throw _abstract();
  }
  insertBefore(el, node) {
    throw _abstract();
  }
  insertAllBefore(el, nodes) {
    throw _abstract();
  }
  insertAfter(el, node) {
    throw _abstract();
  }
  setInnerHTML(el, value) {
    throw _abstract();
  }
  getText(el) {
    throw _abstract();
  }
  setText(el, String value) {
    throw _abstract();
  }
  getValue(el) {
    throw _abstract();
  }
  setValue(el, String value) {
    throw _abstract();
  }
  getChecked(el) {
    throw _abstract();
  }
  setChecked(el, bool value) {
    throw _abstract();
  }
  createTemplate(html) {
    throw _abstract();
  }
  createElement(tagName, [doc = null]) {
    throw _abstract();
  }
  createTextNode(String text, [doc = null]) {
    throw _abstract();
  }
  createScriptTag(String attrName, String attrValue, [doc = null]) {
    throw _abstract();
  }
  createStyleElement(String css, [doc = null]) {
    throw _abstract();
  }
  createShadowRoot(el) {
    throw _abstract();
  }
  getShadowRoot(el) {
    throw _abstract();
  }
  getHost(el) {
    throw _abstract();
  }
  getDistributedNodes(el) {
    throw _abstract();
  }
  clone(node) {
    throw _abstract();
  }
  hasProperty(element, String name) {
    throw _abstract();
  }
  getElementsByClassName(element, String name) {
    throw _abstract();
  }
  getElementsByTagName(element, String name) {
    throw _abstract();
  }
  List classList(element) {
    throw _abstract();
  }
  addClass(element, String classname) {
    throw _abstract();
  }
  removeClass(element, String classname) {
    throw _abstract();
  }
  hasClass(element, String classname) {
    throw _abstract();
  }
  setStyle(element, String stylename, String stylevalue) {
    throw _abstract();
  }
  removeStyle(element, String stylename) {
    throw _abstract();
  }
  getStyle(element, String stylename) {
    throw _abstract();
  }
  String tagName(element) {
    throw _abstract();
  }
  attributeMap(element) {
    throw _abstract();
  }
  String getAttribute(element, String attribute) {
    throw _abstract();
  }
  setAttribute(element, String name, String value) {
    throw _abstract();
  }
  removeAttribute(element, String attribute) {
    throw _abstract();
  }
  templateAwareRoot(el) {
    throw _abstract();
  }
  createHtmlDocument() {
    throw _abstract();
  }
  defaultDoc() {
    throw _abstract();
  }
  getBoundingClientRect(el) {
    throw _abstract();
  }
  getTitle() {
    throw _abstract();
  }
  setTitle(String newTitle) {
    throw _abstract();
  }
  bool elementMatches(n, String selector) {
    throw _abstract();
  }
  bool isTemplateElement(dynamic el) {
    throw _abstract();
  }
  bool isTextNode(node) {
    throw _abstract();
  }
  bool isCommentNode(node) {
    throw _abstract();
  }
  bool isElementNode(node) {
    throw _abstract();
  }
  bool hasShadowRoot(node) {
    throw _abstract();
  }
  bool isShadowRoot(node) {
    throw _abstract();
  }
  importIntoDoc(node) {
    throw _abstract();
  }
  bool isPageRule(rule) {
    throw _abstract();
  }
  bool isStyleRule(rule) {
    throw _abstract();
  }
  bool isMediaRule(rule) {
    throw _abstract();
  }
  bool isKeyframesRule(rule) {
    throw _abstract();
  }
  String getHref(element) {
    throw _abstract();
  }
  String getEventKey(event) {
    throw _abstract();
  }
  resolveAndSetHref(element, String baseUrl, String href) {
    throw _abstract();
  }
  List cssToRules(String css) {
    throw _abstract();
  }
  bool supportsDOMEvents() {
    throw _abstract();
  }
  bool supportsNativeShadowDOM() {
    throw _abstract();
  }
  getGlobalEventTarget(String target) {
    throw _abstract();
  }
  getHistory() {
    throw _abstract();
  }
  getLocation() {
    throw _abstract();
  }
}
