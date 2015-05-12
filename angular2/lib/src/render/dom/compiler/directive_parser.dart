library angular2.src.render.dom.compiler.directive_parser;

import "package:angular2/src/facade/lang.dart"
    show
        isPresent,
        isBlank,
        BaseException,
        assertionsEnabled,
        RegExpWrapper,
        StringWrapper;
import "package:angular2/src/facade/collection.dart"
    show List, MapWrapper, ListWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/change_detection.dart" show Parser;
import "package:angular2/src/render/dom/compiler/selector.dart"
    show SelectorMatcher, CssSelector;
import "compile_step.dart" show CompileStep;
import "compile_element.dart" show CompileElement;
import "compile_control.dart" show CompileControl;
import "../../api.dart" show DirectiveMetadata;
import "../util.dart"
    show dashCaseToCamelCase, camelCaseToDashCase, EVENT_TARGET_SEPARATOR;

/**
 * Parses the directives on a single element. Assumes ViewSplitter has already created
 * <template> elements for template directives.
 */
class DirectiveParser extends CompileStep {
  SelectorMatcher _selectorMatcher;
  List<DirectiveMetadata> _directives;
  Parser _parser;
  DirectiveParser(Parser parser, List<DirectiveMetadata> directives) : super() {
    /* super call moved to initializer */;
    this._parser = parser;
    this._selectorMatcher = new SelectorMatcher();
    this._directives = directives;
    for (var i = 0; i < directives.length; i++) {
      var directive = directives[i];
      var selector = CssSelector.parse(directive.selector);
      this._ensureComponentOnlyHasElementSelector(selector, directive);
      this._selectorMatcher.addSelectables(selector, i);
    }
  }
  _ensureComponentOnlyHasElementSelector(selector, directive) {
    var isElementSelector =
        identical(selector.length, 1) && selector[0].isElementSelector();
    if (!isElementSelector &&
        identical(directive.type, DirectiveMetadata.COMPONENT_TYPE)) {
      throw new BaseException(
          '''Component \'${ directive . id}\' can only have an element selector, but had \'${ directive . selector}\'''');
    }
  }
  process(
      CompileElement parent, CompileElement current, CompileControl control) {
    var attrs = current.attrs();
    var classList = current.classList();
    var cssSelector = new CssSelector();
    var nodeName = DOM.nodeName(current.element);
    cssSelector.setElement(nodeName);
    for (var i = 0; i < classList.length; i++) {
      cssSelector.addClassName(classList[i]);
    }
    MapWrapper.forEach(attrs, (attrValue, attrName) {
      cssSelector.addAttribute(attrName, attrValue);
    });
    var componentDirective;
    this._selectorMatcher.match(cssSelector, (selector, directiveIndex) {
      var elementBinder = current.bindElement();
      var directive = this._directives[directiveIndex];
      var directiveBinderBuilder = elementBinder.bindDirective(directiveIndex);
      current.compileChildren =
          current.compileChildren && directive.compileChildren;
      if (isPresent(directive.properties)) {
        MapWrapper.forEach(directive.properties, (bindConfig, dirProperty) {
          this._bindDirectiveProperty(
              dirProperty, bindConfig, current, directiveBinderBuilder);
        });
      }
      if (isPresent(directive.hostListeners)) {
        MapWrapper.forEach(directive.hostListeners, (action, eventName) {
          this._bindDirectiveEvent(
              eventName, action, current, directiveBinderBuilder);
        });
      }
      if (isPresent(directive.hostActions)) {
        MapWrapper.forEach(directive.hostActions, (action, actionName) {
          this._bindHostAction(
              actionName, action, current, directiveBinderBuilder);
        });
      }
      if (isPresent(directive.hostProperties)) {
        MapWrapper.forEach(directive.hostProperties,
            (hostPropertyName, directivePropertyName) {
          this._bindHostProperty(hostPropertyName, directivePropertyName,
              current, directiveBinderBuilder);
        });
      }
      if (isPresent(directive.hostAttributes)) {
        MapWrapper.forEach(directive.hostAttributes,
            (hostAttrValue, hostAttrName) {
          if (!DOM.hasAttribute(current.element, hostAttrName)) {
            DOM.setAttribute(current.element, hostAttrName, hostAttrValue);
          }
        });
      }
      if (isPresent(directive.readAttributes)) {
        ListWrapper.forEach(directive.readAttributes, (attrName) {
          elementBinder.readAttribute(attrName);
        });
      }
      if (identical(directive.type, DirectiveMetadata.COMPONENT_TYPE)) {
        if (isPresent(componentDirective)) {
          throw new BaseException(
              '''Only one component directive is allowed per element - check ${ current . elementDescription}''');
        }
        componentDirective = directive;
        elementBinder.setComponentId(directive.id);
      }
    });
  }
  _bindDirectiveProperty(
      dirProperty, bindConfig, compileElement, directiveBinderBuilder) {
    var pipes = this._splitBindConfig(bindConfig);
    var elProp = ListWrapper.removeAt(pipes, 0);
    var bindingAst = MapWrapper.get(
        compileElement.bindElement().propertyBindings,
        dashCaseToCamelCase(elProp));
    if (isBlank(bindingAst)) {
      var attributeValue =
          MapWrapper.get(compileElement.attrs(), camelCaseToDashCase(elProp));
      if (isPresent(attributeValue)) {
        bindingAst = this._parser.wrapLiteralPrimitive(
            attributeValue, compileElement.elementDescription);
      }
    }
    // Bindings are optional, so this binding only needs to be set up if an expression is given.
    if (isPresent(bindingAst)) {
      var fullExpAstWithBindPipes = this._parser.addPipes(bindingAst, pipes);
      directiveBinderBuilder.bindProperty(dirProperty, fullExpAstWithBindPipes);
    }
  }
  _bindDirectiveEvent(
      eventName, action, compileElement, directiveBinderBuilder) {
    var ast =
        this._parser.parseAction(action, compileElement.elementDescription);
    if (StringWrapper.contains(eventName, EVENT_TARGET_SEPARATOR)) {
      var parts = eventName.split(EVENT_TARGET_SEPARATOR);
      directiveBinderBuilder.bindEvent(parts[1], ast, parts[0]);
    } else {
      directiveBinderBuilder.bindEvent(eventName, ast);
    }
  }
  _bindHostAction(
      actionName, actionExpression, compileElement, directiveBinderBuilder) {
    var ast = this._parser.parseAction(
        actionExpression, compileElement.elementDescription);
    directiveBinderBuilder.bindHostAction(actionName, actionExpression, ast);
  }
  _bindHostProperty(hostPropertyName, directivePropertyName, compileElement,
      directiveBinderBuilder) {
    var ast = this._parser.parseBinding(directivePropertyName,
        '''hostProperties of ${ compileElement . elementDescription}''');
    directiveBinderBuilder.bindHostProperty(hostPropertyName, ast);
  }
  _splitBindConfig(String bindConfig) {
    return ListWrapper.map(bindConfig.split("|"), (s) => s.trim());
  }
}
