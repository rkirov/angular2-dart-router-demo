library benchmarks.src.tree.tree_benchmark;

import "package:angular2/angular2.dart"
    show
        bootstrap,
        ViewContainerRef,
        Compiler; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/life_cycle/life_cycle.dart" show LifeCycle;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/facade/collection.dart" show List;
import "package:angular2/src/facade/browser.dart" show window, document, gc;
import "package:angular2/src/test_lib/benchmark_util.dart"
    show getIntParameter, getStringParameter, bindAction;
import "package:angular2/directives.dart" show If;
import "package:angular2/src/dom/browser_adapter.dart" show BrowserDomAdapter;
import "package:angular2/src/core/compiler/view_pool.dart"
    show APP_VIEW_POOL_CAPACITY;
import "package:angular2/src/render/dom/view/view_factory.dart" as rvf;
import "package:angular2/di.dart" show bind;

List createBindings() {
  var viewCacheCapacity = getStringParameter("viewcache") == "true" ? 10000 : 1;
  return [
    bind(rvf.VIEW_POOL_CAPACITY).toValue(viewCacheCapacity),
    bind(APP_VIEW_POOL_CAPACITY).toValue(viewCacheCapacity)
  ];
}
setupReflector() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
}
var BASELINE_TREE_TEMPLATE;
var BASELINE_IF_TEMPLATE;
main() {
  BrowserDomAdapter.makeCurrent();
  var maxDepth = getIntParameter("depth");
  setupReflector();
  BASELINE_TREE_TEMPLATE = DOM.createTemplate(
      "<span>_<template class=\"ng-binding\"></template><template class=\"ng-binding\"></template></span>");
  BASELINE_IF_TEMPLATE =
      DOM.createTemplate("<span template=\"if\"><tree></tree></span>");
  var app;
  var lifeCycle;
  var baselineRootTreeComponent;
  var count = 0;
  ng2DestroyDom() {
    // TODO: We need an initial value as otherwise the getter for data.value will fail
    // --> this should be already caught in change detection!
    app.initData = new TreeNode("", null, null);
    lifeCycle.tick();
  }
  profile(create, destroy, name) {
    return () {
      window.console.profile(name + " w GC");
      var duration = 0;
      var count = 0;
      while (count++ < 150) {
        gc();
        var start = window.performance.now();
        create();
        duration += window.performance.now() - start;
        destroy();
      }
      window.console.profileEnd(name + " w GC");
      window.console.log(
          '''Iterations: ${ count}; time: ${ duration / count} ms / iteration''');
      window.console.profile(name + " w/o GC");
      duration = 0;
      count = 0;
      while (count++ < 150) {
        var start = window.performance.now();
        create();
        duration += window.performance.now() - start;
        destroy();
      }
      window.console.profileEnd(name + " w/o GC");
      window.console.log(
          '''Iterations: ${ count}; time: ${ duration / count} ms / iteration''');
    };
  }
  ng2CreateDom() {
    var values = count++ % 2 == 0
        ? ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "*"]
        : ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "-"];
    app.initData = buildTree(maxDepth, values, 0);
    lifeCycle.tick();
  }
  noop() {}
  initNg2() {
    bootstrap(AppComponent, createBindings()).then((ref) {
      var injector = ref.injector;
      lifeCycle = injector.get(LifeCycle);
      app = injector.get(AppComponent);
      bindAction("#ng2DestroyDom", ng2DestroyDom);
      bindAction("#ng2CreateDom", ng2CreateDom);
      bindAction(
          "#ng2UpdateDomProfile", profile(ng2CreateDom, noop, "ng2-update"));
      bindAction("#ng2CreateDomProfile",
          profile(ng2CreateDom, ng2DestroyDom, "ng2-create"));
    });
  }
  baselineDestroyDom() {
    baselineRootTreeComponent.update(new TreeNode("", null, null));
  }
  baselineCreateDom() {
    var values = count++ % 2 == 0
        ? ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "*"]
        : ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "-"];
    baselineRootTreeComponent.update(buildTree(maxDepth, values, 0));
  }
  initBaseline() {
    var tree = DOM.createElement("tree");
    DOM.appendChild(DOM.querySelector(document, "baseline"), tree);
    baselineRootTreeComponent = new BaseLineTreeComponent(tree);
    bindAction("#baselineDestroyDom", baselineDestroyDom);
    bindAction("#baselineCreateDom", baselineCreateDom);
    bindAction("#baselineUpdateDomProfile",
        profile(baselineCreateDom, noop, "baseline-update"));
    bindAction("#baselineCreateDomProfile",
        profile(baselineCreateDom, baselineDestroyDom, "baseline-create"));
  }
  initNg2();
  initBaseline();
}
class TreeNode {
  String value;
  TreeNode left;
  TreeNode right;
  TreeNode(value, left, right) {
    this.value = value;
    this.left = left;
    this.right = right;
  }
}
buildTree(maxDepth, values, curDepth) {
  if (identical(maxDepth, curDepth)) return new TreeNode("", null, null);
  return new TreeNode(values[curDepth],
      buildTree(maxDepth, values, curDepth + 1),
      buildTree(maxDepth, values, curDepth + 1));
} // http://jsperf.com/nextsibling-vs-childnodes
class BaseLineTreeComponent {
  var element;
  BaseLineInterpolation value;
  BaseLineIf left;
  BaseLineIf right;
  BaseLineTreeComponent(element) {
    this.element = element;
    var clone = DOM.clone(BASELINE_TREE_TEMPLATE.content.firstChild);
    var shadowRoot = this.element.createShadowRoot();
    DOM.appendChild(shadowRoot, clone);
    var child = clone.firstChild;
    this.value = new BaseLineInterpolation(child);
    child = DOM.nextSibling(child);
    this.left = new BaseLineIf(child);
    child = DOM.nextSibling(child);
    this.right = new BaseLineIf(child);
  }
  update(TreeNode value) {
    this.value.update(value.value);
    this.left.update(value.left);
    this.right.update(value.right);
  }
}
class BaseLineInterpolation {
  String value;
  var textNode;
  BaseLineInterpolation(textNode) {
    this.value = null;
    this.textNode = textNode;
  }
  update(String value) {
    if (!identical(this.value, value)) {
      this.value = value;
      DOM.setText(this.textNode, value + " ");
    }
  }
}
class BaseLineIf {
  bool condition;
  BaseLineTreeComponent component;
  var anchor;
  BaseLineIf(anchor) {
    this.anchor = anchor;
    this.condition = false;
    this.component = null;
  }
  update(TreeNode value) {
    var newCondition = isPresent(value);
    if (!identical(this.condition, newCondition)) {
      this.condition = newCondition;
      if (isPresent(this.component)) {
        DOM.remove(this.component.element);
        this.component = null;
      }
      if (this.condition) {
        var element = DOM.firstChild(DOM.clone(BASELINE_IF_TEMPLATE).content);
        this.anchor.parentNode.insertBefore(
            element, DOM.nextSibling(this.anchor));
        this.component = new BaseLineTreeComponent(DOM.firstChild(element));
      }
    }
    if (isPresent(this.component)) {
      this.component.update(value);
    }
  }
}
@Component(selector: "app")
@View(
    directives: const [TreeComponent],
    template: '''<tree [data]=\'initData\'></tree>''')
class AppComponent {
  TreeNode initData;
  AppComponent() {
    // TODO: We need an initial value as otherwise the getter for data.value will fail
    // --> this should be already caught in change detection!
    this.initData = new TreeNode("", null, null);
  }
}
@Component(selector: "tree", properties: const {"data": "data"})
@View(
    directives: const [TreeComponent, If],
    template: '''<span> {{data.value}} <span template=\'if data.right != null\'><tree [data]=\'data.right\'></tree></span><span template=\'if data.left != null\'><tree [data]=\'data.left\'></tree></span></span>''')
class TreeComponent {
  TreeNode data;
}
