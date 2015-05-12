library angular2.src.render.dom.shadow_dom.shadow_dom_compile_step;

import "package:angular2/src/facade/lang.dart"
    show isBlank, isPresent, assertionsEnabled;
import "package:angular2/src/facade/collection.dart"
    show MapWrapper, List, ListWrapper;
import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "../compiler/compile_step.dart" show CompileStep;
import "../compiler/compile_element.dart" show CompileElement;
import "../compiler/compile_control.dart" show CompileControl;
import "../../api.dart" show ViewDefinition;
import "shadow_dom_strategy.dart" show ShadowDomStrategy;

class ShadowDomCompileStep extends CompileStep {
  ShadowDomStrategy _shadowDomStrategy;
  ViewDefinition _template;
  List<Future> _subTaskPromises;
  ShadowDomCompileStep(ShadowDomStrategy shadowDomStrategy,
      ViewDefinition template, List<Future> subTaskPromises)
      : super() {
    /* super call moved to initializer */;
    this._shadowDomStrategy = shadowDomStrategy;
    this._template = template;
    this._subTaskPromises = subTaskPromises;
  }
  process(
      CompileElement parent, CompileElement current, CompileControl control) {
    var tagName = DOM.tagName(current.element).toUpperCase();
    if (tagName == "STYLE") {
      this._processStyleElement(current, control);
    } else if (tagName == "CONTENT") {
      this._processContentElement(current);
    } else {
      var componentId =
          current.isBound() ? current.inheritedElementBinder.componentId : null;
      this._shadowDomStrategy.processElement(
          this._template.componentId, componentId, current.element);
    }
  }
  _processStyleElement(CompileElement current, CompileControl control) {
    var stylePromise = this._shadowDomStrategy.processStyleElement(
        this._template.componentId, this._template.absUrl, current.element);
    if (isPresent(stylePromise) && PromiseWrapper.isPromise(stylePromise)) {
      ListWrapper.push(this._subTaskPromises, stylePromise);
    }
    // Style elements should not be further processed by the compiler, as they can not contain

    // bindings. Skipping further compiler steps allow speeding up the compilation process.
    control.ignoreCurrentElement();
  }
  _processContentElement(CompileElement current) {
    if (this._shadowDomStrategy.hasNativeContentElement()) {
      return;
    }
    var attrs = current.attrs();
    var selector = MapWrapper.get(attrs, "select");
    selector = isPresent(selector) ? selector : "";
    var contentStart = DOM.createScriptTag("type", "ng/contentStart");
    if (assertionsEnabled()) {
      DOM.setAttribute(contentStart, "select", selector);
    }
    var contentEnd = DOM.createScriptTag("type", "ng/contentEnd");
    DOM.insertBefore(current.element, contentStart);
    DOM.insertBefore(current.element, contentEnd);
    DOM.remove(current.element);
    current.element = contentStart;
    current.bindElement().setContentTagSelector(selector);
  }
}
