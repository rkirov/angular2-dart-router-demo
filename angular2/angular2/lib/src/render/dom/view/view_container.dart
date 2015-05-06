library angular2.src.render.dom.view.view_container;

import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, BaseException;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, List;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "view.dart" as viewModule;

class ViewContainer {
  viewModule.RenderView parentView;
  num boundElementIndex;
  List<viewModule.RenderView> views;
  ViewContainer(viewModule.RenderView parentView, num boundElementIndex) {
    this.parentView = parentView;
    this.boundElementIndex =
        boundElementIndex; // The order in this list matches the DOM order.
    this.views = [];
  }
  viewModule.RenderView get(num index) {
    return this.views[index];
  }
  size() {
    return this.views.length;
  }
  _siblingToInsertAfter(num index) {
    if (index == 0) return this.parentView.boundElements[
        this.boundElementIndex];
    return ListWrapper.last(this.views[index - 1].rootNodes);
  }
  _checkHydrated() {
    if (!this.parentView.hydrated) throw new BaseException(
        "Cannot change dehydrated ViewContainer");
  }
  _getDirectParentLightDom() {
    return this.parentView.getDirectParentLightDom(this.boundElementIndex);
  }
  clear() {
    this._checkHydrated();
    for (var i = this.views.length - 1; i >= 0; i--) {
      this.detach(i);
    }
    if (isPresent(this._getDirectParentLightDom())) {
      this._getDirectParentLightDom().redistribute();
    }
  }
  viewModule.RenderView insert(view, [atIndex = -1]) {
    this._checkHydrated();
    if (atIndex == -1) atIndex = this.views.length;
    ListWrapper.insert(this.views, atIndex, view);
    if (isBlank(this._getDirectParentLightDom())) {
      ViewContainer.moveViewNodesAfterSibling(
          this._siblingToInsertAfter(atIndex), view);
    } else {
      this._getDirectParentLightDom().redistribute();
    } // new content tags might have appeared, we need to redistribute.
    if (isPresent(this.parentView.hostLightDom)) {
      this.parentView.hostLightDom.redistribute();
    }
    return view;
  } /**
   * The method can be used together with insert to implement a view move, i.e.
   * moving the dom nodes while the directives in the view stay intact.
   */
  detach(num atIndex) {
    this._checkHydrated();
    var detachedView = this.get(atIndex);
    ListWrapper.removeAt(this.views, atIndex);
    if (isBlank(this._getDirectParentLightDom())) {
      ViewContainer.removeViewNodes(detachedView);
    } else {
      this._getDirectParentLightDom().redistribute();
    } // content tags might have disappeared we need to do redistribution.
    if (isPresent(this.parentView.hostLightDom)) {
      this.parentView.hostLightDom.redistribute();
    }
    return detachedView;
  }
  contentTagContainers() {
    return this.views;
  }
  List nodes() {
    var r = [];
    for (var i = 0; i < this.views.length; ++i) {
      r = ListWrapper.concat(r, this.views[i].rootNodes);
    }
    return r;
  }
  static moveViewNodesAfterSibling(sibling, view) {
    for (var i = view.rootNodes.length - 1; i >= 0; --i) {
      DOM.insertAfter(sibling, view.rootNodes[i]);
    }
  }
  static removeViewNodes(view) {
    var len = view.rootNodes.length;
    if (len == 0) return;
    var parent = view.rootNodes[0].parentNode;
    for (var i = len - 1; i >= 0; --i) {
      DOM.removeChild(parent, view.rootNodes[i]);
    }
  }
}
