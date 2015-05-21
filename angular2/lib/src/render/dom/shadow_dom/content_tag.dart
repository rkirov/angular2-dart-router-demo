library angular2.src.render.dom.shadow_dom.content_tag;

import "light_dom.dart" as ldModule;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;

class ContentStrategy {
  List<dynamic> nodes;
  insert(List<dynamic> nodes) {}
}
/**
 * An implementation of the content tag that is used by transcluding components.
 * It is used when the content tag is not a direct child of another component,
 * and thus does not affect redistribution.
 */
class RenderedContent extends ContentStrategy {
  var beginScript;
  var endScript;
  RenderedContent(contentEl) : super() {
    /* super call moved to initializer */;
    this.beginScript = contentEl;
    this.endScript = DOM.nextSibling(this.beginScript);
    this.nodes = [];
  }
  // Inserts the nodes in between the start and end scripts.

  // Previous content is removed.
  insert(List<dynamic> nodes) {
    this.nodes = nodes;
    DOM.insertAllBefore(this.endScript, nodes);
    this._removeNodesUntil(
        ListWrapper.isEmpty(nodes) ? this.endScript : nodes[0]);
  }
  _removeNodesUntil(node) {
    var p = DOM.parentElement(this.beginScript);
    for (var next = DOM.nextSibling(this.beginScript);
        !identical(next, node);
        next = DOM.nextSibling(this.beginScript)) {
      DOM.removeChild(p, next);
    }
  }
}
/**
 * An implementation of the content tag that is used by transcluding components.
 * It is used when the content tag is a direct child of another component,
 * and thus does not get rendered but only affect the distribution of its parent component.
 */
class IntermediateContent extends ContentStrategy {
  ldModule.LightDom destinationLightDom;
  IntermediateContent(ldModule.LightDom destinationLightDom) : super() {
    /* super call moved to initializer */;
    this.nodes = [];
    this.destinationLightDom = destinationLightDom;
  }
  insert(List<dynamic> nodes) {
    this.nodes = nodes;
    this.destinationLightDom.redistribute();
  }
}
class Content {
  String select;
  ContentStrategy _strategy;
  var contentStartElement;
  Content(contentStartEl, String selector) {
    this.select = selector;
    this.contentStartElement = contentStartEl;
    this._strategy = null;
  }
  init(ldModule.LightDom destinationLightDom) {
    this._strategy = isPresent(destinationLightDom)
        ? new IntermediateContent(destinationLightDom)
        : new RenderedContent(this.contentStartElement);
  }
  List<dynamic> nodes() {
    return this._strategy.nodes;
  }
  insert(List<dynamic> nodes) {
    this._strategy.insert(nodes);
  }
}
