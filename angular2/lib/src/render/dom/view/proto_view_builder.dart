library angular2.src.render.dom.view.proto_view_builder;

import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, BaseException;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Set, SetWrapper, List;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/change_detection.dart"
    show
        ASTWithSource,
        AST,
        AstTransformer,
        AccessMember,
        LiteralArray,
        ImplicitReceiver;
import "proto_view.dart"
    show DomProtoView, DomProtoViewRef, resolveInternalDomProtoView;
import "element_binder.dart" show ElementBinder, Event, HostAction;
import "property_setter_factory.dart" show setterFactory;
import "../../api.dart" as api;
import "../util.dart" show NG_BINDING_CLASS, EVENT_TARGET_SEPARATOR;

class ProtoViewBuilder {
  var rootElement;
  Map<String, String> variableBindings;
  List<ElementBinderBuilder> elements;
  ProtoViewBuilder(rootElement) {
    this.rootElement = rootElement;
    this.elements = [];
    this.variableBindings = MapWrapper.create();
  }
  ElementBinderBuilder bindElement(element, [description = null]) {
    var builder =
        new ElementBinderBuilder(this.elements.length, element, description);
    ListWrapper.push(this.elements, builder);
    DOM.addClass(element, NG_BINDING_CLASS);
    return builder;
  }
  bindVariable(name, value) {
    // Store the variable map from value to variable, reflecting how it will be used later by

    // DomView. When a local is set to the view, a lookup for the variable name will take place keyed

    // by the "value", or exported identifier. For example, ng-repeat sets a view local of "index".

    // When this occurs, a lookup keyed by "index" must occur to find if there is a var referencing

    // it.
    MapWrapper.set(this.variableBindings, value, name);
  }
  api.ProtoViewDto build() {
    var renderElementBinders = [];
    var apiElementBinders = [];
    ListWrapper.forEach(this.elements, (ebb) {
      var propertySetters = MapWrapper.create();
      var hostActions = MapWrapper.create();
      var apiDirectiveBinders = ListWrapper.map(ebb.directives, (dbb) {
        ebb.eventBuilder.merge(dbb.eventBuilder);
        MapWrapper.forEach(dbb.hostPropertyBindings, (_, hostPropertyName) {
          MapWrapper.set(propertySetters, hostPropertyName,
              setterFactory(hostPropertyName));
        });
        ListWrapper.forEach(dbb.hostActions, (hostAction) {
          MapWrapper.set(
              hostActions, hostAction.actionExpression, hostAction.expression);
        });
        return new api.DirectiveBinder(
            directiveIndex: dbb.directiveIndex,
            propertyBindings: dbb.propertyBindings,
            eventBindings: dbb.eventBindings,
            hostPropertyBindings: dbb.hostPropertyBindings);
      });
      MapWrapper.forEach(ebb.propertyBindings, (_, propertyName) {
        MapWrapper.set(
            propertySetters, propertyName, setterFactory(propertyName));
      });
      var nestedProtoView =
          isPresent(ebb.nestedProtoView) ? ebb.nestedProtoView.build() : null;
      var parentIndex = isPresent(ebb.parent) ? ebb.parent.index : -1;
      ListWrapper.push(apiElementBinders, new api.ElementBinder(
          index: ebb.index,
          parentIndex: parentIndex,
          distanceToParent: ebb.distanceToParent,
          directives: apiDirectiveBinders,
          nestedProtoView: nestedProtoView,
          propertyBindings: ebb.propertyBindings,
          variableBindings: ebb.variableBindings,
          eventBindings: ebb.eventBindings,
          textBindings: ebb.textBindings,
          readAttributes: ebb.readAttributes));
      ListWrapper.push(renderElementBinders, new ElementBinder(
          textNodeIndices: ebb.textBindingIndices,
          contentTagSelector: ebb.contentTagSelector,
          parentIndex: parentIndex,
          distanceToParent: ebb.distanceToParent,
          nestedProtoView: isPresent(nestedProtoView)
              ? resolveInternalDomProtoView(nestedProtoView.render)
              : null,
          componentId: ebb.componentId,
          eventLocals: new LiteralArray(ebb.eventBuilder.buildEventLocals()),
          localEvents: ebb.eventBuilder.buildLocalEvents(),
          globalEvents: ebb.eventBuilder.buildGlobalEvents(),
          hostActions: hostActions,
          propertySetters: propertySetters));
    });
    return new api.ProtoViewDto(
        render: new DomProtoViewRef(new DomProtoView(
            element: this.rootElement, elementBinders: renderElementBinders)),
        elementBinders: apiElementBinders,
        variableBindings: this.variableBindings);
  }
}
class ElementBinderBuilder {
  var element;
  num index;
  ElementBinderBuilder parent;
  num distanceToParent;
  List<DirectiveBuilder> directives;
  ProtoViewBuilder nestedProtoView;
  Map<String, ASTWithSource> propertyBindings;
  Map<String, String> variableBindings;
  List<api.EventBinding> eventBindings;
  EventBuilder eventBuilder;
  List<num> textBindingIndices;
  List<ASTWithSource> textBindings;
  String contentTagSelector;
  Map<String, String> readAttributes;
  String componentId;
  ElementBinderBuilder(index, element, description) {
    this.element = element;
    this.index = index;
    this.parent = null;
    this.distanceToParent = 0;
    this.directives = [];
    this.nestedProtoView = null;
    this.propertyBindings = MapWrapper.create();
    this.variableBindings = MapWrapper.create();
    this.eventBindings = ListWrapper.create();
    this.eventBuilder = new EventBuilder();
    this.textBindings = [];
    this.textBindingIndices = [];
    this.contentTagSelector = null;
    this.componentId = null;
    this.readAttributes = MapWrapper.create();
  }
  ElementBinderBuilder setParent(
      ElementBinderBuilder parent, distanceToParent) {
    this.parent = parent;
    if (isPresent(parent)) {
      this.distanceToParent = distanceToParent;
    }
    return this;
  }
  readAttribute(String attrName) {
    if (isBlank(MapWrapper.get(this.readAttributes, attrName))) {
      MapWrapper.set(this.readAttributes, attrName,
          DOM.getAttribute(this.element, attrName));
    }
  }
  DirectiveBuilder bindDirective(num directiveIndex) {
    var directive = new DirectiveBuilder(directiveIndex);
    ListWrapper.push(this.directives, directive);
    return directive;
  }
  ProtoViewBuilder bindNestedProtoView(rootElement) {
    if (isPresent(this.nestedProtoView)) {
      throw new BaseException("Only one nested view per element is allowed");
    }
    this.nestedProtoView = new ProtoViewBuilder(rootElement);
    return this.nestedProtoView;
  }
  bindProperty(name, expression) {
    MapWrapper.set(this.propertyBindings, name, expression);
    //TODO: required for Dart transformers. Remove when Dart transformers

    //run all the steps of the render compiler
    setterFactory(name);
  }
  bindVariable(name, value) {
    // When current is a view root, the variable bindings are set to the *nested* proto view.

    // The root view conceptually signifies a new "block scope" (the nested view), to which

    // the variables are bound.
    if (isPresent(this.nestedProtoView)) {
      this.nestedProtoView.bindVariable(name, value);
    } else {
      // Store the variable map from value to variable, reflecting how it will be used later by

      // DomView. When a local is set to the view, a lookup for the variable name will take place keyed

      // by the "value", or exported identifier. For example, ng-repeat sets a view local of "index".

      // When this occurs, a lookup keyed by "index" must occur to find if there is a var referencing

      // it.
      MapWrapper.set(this.variableBindings, value, name);
    }
  }
  bindEvent(name, expression, [target = null]) {
    ListWrapper.push(
        this.eventBindings, this.eventBuilder.add(name, expression, target));
  }
  bindText(index, expression) {
    ListWrapper.push(this.textBindingIndices, index);
    ListWrapper.push(this.textBindings, expression);
  }
  setContentTagSelector(String value) {
    this.contentTagSelector = value;
  }
  setComponentId(String componentId) {
    this.componentId = componentId;
  }
}
class DirectiveBuilder {
  num directiveIndex;
  Map<String, ASTWithSource> propertyBindings;
  Map<String, ASTWithSource> hostPropertyBindings;
  List<HostAction> hostActions;
  List<api.EventBinding> eventBindings;
  EventBuilder eventBuilder;
  DirectiveBuilder(directiveIndex) {
    this.directiveIndex = directiveIndex;
    this.propertyBindings = MapWrapper.create();
    this.hostPropertyBindings = MapWrapper.create();
    this.hostActions = ListWrapper.create();
    this.eventBindings = ListWrapper.create();
    this.eventBuilder = new EventBuilder();
  }
  bindProperty(name, expression) {
    MapWrapper.set(this.propertyBindings, name, expression);
  }
  bindHostProperty(name, expression) {
    MapWrapper.set(this.hostPropertyBindings, name, expression);
  }
  bindHostAction(
      String actionName, String actionExpression, ASTWithSource expression) {
    ListWrapper.push(this.hostActions,
        new HostAction(actionName, actionExpression, expression));
  }
  bindEvent(name, expression, [target = null]) {
    ListWrapper.push(
        this.eventBindings, this.eventBuilder.add(name, expression, target));
  }
}
class EventBuilder extends AstTransformer {
  List<AST> locals;
  List<Event> localEvents;
  List<Event> globalEvents;
  AST _implicitReceiver;
  EventBuilder() : super() {
    /* super call moved to initializer */;
    this.locals = [];
    this.localEvents = [];
    this.globalEvents = [];
    this._implicitReceiver = new ImplicitReceiver();
  }
  api.EventBinding add(String name, ASTWithSource source, String target) {
    // TODO(tbosch): reenable this when we are parsing element properties

    // out of action expressions

    // var adjustedAst = astWithSource.ast.visit(this);
    var adjustedAst = source.ast;
    var fullName =
        isPresent(target) ? target + EVENT_TARGET_SEPARATOR + name : name;
    var result = new api.EventBinding(fullName,
        new ASTWithSource(adjustedAst, source.source, source.location));
    var event = new Event(name, target, fullName);
    if (isBlank(target)) {
      ListWrapper.push(this.localEvents, event);
    } else {
      ListWrapper.push(this.globalEvents, event);
    }
    return result;
  }
  visitAccessMember(AccessMember ast) {
    var isEventAccess = false;
    var current = ast;
    while (!isEventAccess && (current is AccessMember)) {
      if (current.name == "\$event") {
        isEventAccess = true;
      }
      current = current.receiver;
    }
    if (isEventAccess) {
      ListWrapper.push(this.locals, ast);
      var index = this.locals.length - 1;
      return new AccessMember(
          this._implicitReceiver, '''${ index}''', (arr) => arr[index], null);
    } else {
      return ast;
    }
  }
  buildEventLocals() {
    return this.locals;
  }
  buildLocalEvents() {
    return this.localEvents;
  }
  buildGlobalEvents() {
    return this.globalEvents;
  }
  merge(EventBuilder eventBuilder) {
    this._merge(this.localEvents, eventBuilder.localEvents);
    this._merge(this.globalEvents, eventBuilder.globalEvents);
    ListWrapper.concat(this.locals, eventBuilder.locals);
  }
  _merge(List<Event> host, List<Event> tobeAdded) {
    var names = ListWrapper.create();
    for (var i = 0; i < host.length; i++) {
      ListWrapper.push(names, host[i].fullName);
    }
    for (var j = 0; j < tobeAdded.length; j++) {
      if (!ListWrapper.contains(names, tobeAdded[j].fullName)) {
        ListWrapper.push(host, tobeAdded[j]);
      }
    }
  }
}
