library angular2.src.render.dom.view.property_setter_factory;

import "package:angular2/src/facade/lang.dart"
    show
        StringWrapper,
        RegExpWrapper,
        BaseException,
        isPresent,
        isBlank,
        isString,
        stringify;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, StringMapWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "../util.dart" show camelCaseToDashCase, dashCaseToCamelCase;
import "package:angular2/src/reflection/reflection.dart" show reflector;

const STYLE_SEPARATOR = ".";
var propertySettersCache = StringMapWrapper.create();
var innerHTMLSetterCache;
const ATTRIBUTE_PREFIX = "attr.";
var attributeSettersCache = StringMapWrapper.create();
const CLASS_PREFIX = "class.";
var classSettersCache = StringMapWrapper.create();
const STYLE_PREFIX = "style.";
var styleSettersCache = StringMapWrapper.create();
Function setterFactory(String property) {
  var setterFn, styleParts, styleSuffix;
  if (StringWrapper.startsWith(property, ATTRIBUTE_PREFIX)) {
    setterFn = attributeSetterFactory(
        StringWrapper.substring(property, ATTRIBUTE_PREFIX.length));
  } else if (StringWrapper.startsWith(property, CLASS_PREFIX)) {
    setterFn = classSetterFactory(
        StringWrapper.substring(property, CLASS_PREFIX.length));
  } else if (StringWrapper.startsWith(property, STYLE_PREFIX)) {
    styleParts = property.split(STYLE_SEPARATOR);
    styleSuffix = styleParts.length > 2 ? ListWrapper.get(styleParts, 2) : "";
    setterFn = styleSetterFactory(ListWrapper.get(styleParts, 1), styleSuffix);
  } else if (StringWrapper.equals(property, "innerHtml")) {
    if (isBlank(innerHTMLSetterCache)) {
      innerHTMLSetterCache = (el, value) => DOM.setInnerHTML(el, value);
    }
    setterFn = innerHTMLSetterCache;
  } else {
    property = resolvePropertyName(property);
    setterFn = StringMapWrapper.get(propertySettersCache, property);
    if (isBlank(setterFn)) {
      var propertySetterFn = reflector.setter(property);
      setterFn = (receiver, value) {
        if (DOM.hasProperty(receiver, property)) {
          return propertySetterFn(receiver, value);
        }
      };
      StringMapWrapper.set(propertySettersCache, property, setterFn);
    }
  }
  return setterFn;
}
bool _isValidAttributeValue(String attrName, dynamic value) {
  if (attrName == "role") {
    return isString(value);
  } else {
    return isPresent(value);
  }
}
Function attributeSetterFactory(String attrName) {
  var setterFn = StringMapWrapper.get(attributeSettersCache, attrName);
  var dashCasedAttributeName;
  if (isBlank(setterFn)) {
    dashCasedAttributeName = camelCaseToDashCase(attrName);
    setterFn = (element, value) {
      if (_isValidAttributeValue(dashCasedAttributeName, value)) {
        DOM.setAttribute(element, dashCasedAttributeName, stringify(value));
      } else {
        if (isPresent(value)) {
          throw new BaseException("Invalid " +
              dashCasedAttributeName +
              " attribute, only string values are allowed, got '" +
              stringify(value) +
              "'");
        }
        DOM.removeAttribute(element, dashCasedAttributeName);
      }
    };
    StringMapWrapper.set(attributeSettersCache, attrName, setterFn);
  }
  return setterFn;
}
Function classSetterFactory(String className) {
  var setterFn = StringMapWrapper.get(classSettersCache, className);
  var dashCasedClassName;
  if (isBlank(setterFn)) {
    dashCasedClassName = camelCaseToDashCase(className);
    setterFn = (element, value) {
      if (value) {
        DOM.addClass(element, dashCasedClassName);
      } else {
        DOM.removeClass(element, dashCasedClassName);
      }
    };
    StringMapWrapper.set(classSettersCache, className, setterFn);
  }
  return setterFn;
}
Function styleSetterFactory(String styleName, String styleSuffix) {
  var cacheKey = styleName + styleSuffix;
  var setterFn = StringMapWrapper.get(styleSettersCache, cacheKey);
  var dashCasedStyleName;
  if (isBlank(setterFn)) {
    dashCasedStyleName = camelCaseToDashCase(styleName);
    setterFn = (element, value) {
      var valAsStr;
      if (isPresent(value)) {
        valAsStr = stringify(value);
        DOM.setStyle(element, dashCasedStyleName, valAsStr + styleSuffix);
      } else {
        DOM.removeStyle(element, dashCasedStyleName);
      }
    };
    StringMapWrapper.set(styleSettersCache, cacheKey, setterFn);
  }
  return setterFn;
}
String resolvePropertyName(String attrName) {
  var mappedPropName = StringMapWrapper.get(DOM.attrToPropMap, attrName);
  return isPresent(mappedPropName) ? mappedPropName : attrName;
}
