library angular2.src.render.dom.compiler.compile_pipeline;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "compile_element.dart" show CompileElement;
import "compile_control.dart" show CompileControl;
import "compile_step.dart" show CompileStep;
import "../view/proto_view_builder.dart"
    show
        ProtoViewBuilder; /**
 * CompilePipeline for executing CompileSteps recursively for
 * all elements in a template.
 */

class CompilePipeline {
  CompileControl _control;
  CompilePipeline(List<CompileStep> steps) {
    this._control = new CompileControl(steps);
  }
  List process(rootElement, [String compilationCtxtDescription = ""]) {
    var results = ListWrapper.create();
    var rootCompileElement =
        new CompileElement(rootElement, compilationCtxtDescription);
    rootCompileElement.inheritedProtoView = new ProtoViewBuilder(rootElement);
    rootCompileElement.isViewRoot = true;
    this._process(
        results, null, rootCompileElement, compilationCtxtDescription);
    return results;
  }
  _process(results, CompileElement parent, CompileElement current,
      [String compilationCtxtDescription = ""]) {
    var additionalChildren =
        this._control.internalProcess(results, 0, parent, current);
    if (current.compileChildren) {
      var node = DOM.firstChild(DOM.templateAwareRoot(current.element));
      while (isPresent(node)) {
        // compiliation can potentially move the node, so we need to store the
        // next sibling before recursing.
        var nextNode = DOM.nextSibling(node);
        if (DOM.isElementNode(node)) {
          var childCompileElement =
              new CompileElement(node, compilationCtxtDescription);
          childCompileElement.inheritedProtoView = current.inheritedProtoView;
          childCompileElement.inheritedElementBinder =
              current.inheritedElementBinder;
          childCompileElement.distanceToInheritedBinder =
              current.distanceToInheritedBinder + 1;
          this._process(results, current, childCompileElement);
        }
        node = nextNode;
      }
    }
    if (isPresent(additionalChildren)) {
      for (var i = 0; i < additionalChildren.length; i++) {
        this._process(results, current, additionalChildren[i]);
      }
    }
  }
}
