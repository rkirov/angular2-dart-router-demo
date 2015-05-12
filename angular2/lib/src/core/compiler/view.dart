library angular2.src.core.compiler.view;

import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, StringMapWrapper, List;
import "package:angular2/change_detection.dart"
    show
        AST,
        Locals,
        ChangeDispatcher,
        ProtoChangeDetector,
        ChangeDetector,
        ChangeRecord,
        BindingRecord,
        DirectiveRecord,
        DirectiveIndex,
        ChangeDetectorRef;
import "element_injector.dart"
    show
        ProtoElementInjector,
        ElementInjector,
        PreBuiltObjects,
        DirectiveBinding;
import "element_binder.dart" show ElementBinder;
import "package:angular2/src/facade/lang.dart"
    show int, isPresent, isBlank, BaseException;
import "package:angular2/src/render/api.dart" as renderApi;

class AppViewContainer {
  List<AppView> views;
  AppViewContainer() {
    // The order in this list matches the DOM order.
    this.views = [];
  }
}
/**
 * Const of making objects: http://jsperf.com/instantiate-size-of-object
 *
 */
class AppView implements ChangeDispatcher {
  renderApi.RenderViewRef render;
  /// This list matches the _nodes list. It is sparse, since only Elements have ElementInjector
  List<ElementInjector> rootElementInjectors;
  List<ElementInjector> elementInjectors;
  ChangeDetector changeDetector;
  List<AppView> componentChildViews;
  /// Host views that were added by an imperative view.

  /// This is a dynamically growing / shrinking array.
  List<AppView> inPlaceHostViews;
  List<AppViewContainer> viewContainers;
  List<PreBuiltObjects> preBuiltObjects;
  AppProtoView proto;
  renderApi.Renderer renderer;
  /**
   * The context against which data-binding expressions in this view are evaluated against.
   * This is always a component instance.
   */
  dynamic context;
  /**
   * Variables, local to this view, that can be used in binding expressions (in addition to the
   * context). This is used for thing like `<video #player>` or
   * `<li template="for #item of items">`, where "player" and "item" are locals, respectively.
   */
  Locals locals;
  AppView(renderApi.Renderer renderer, AppProtoView proto, Map protoLocals) {
    this.render = null;
    this.proto = proto;
    this.changeDetector = null;
    this.elementInjectors = null;
    this.rootElementInjectors = null;
    this.componentChildViews = null;
    this.viewContainers =
        ListWrapper.createFixedSize(this.proto.elementBinders.length);
    this.preBuiltObjects = null;
    this.context = null;
    this.locals = new Locals(null, MapWrapper.clone(protoLocals));
    this.renderer = renderer;
    this.inPlaceHostViews = [];
  }
  init(ChangeDetector changeDetector, List elementInjectors,
      List rootElementInjectors, List preBuiltObjects,
      List componentChildViews) {
    this.changeDetector = changeDetector;
    this.elementInjectors = elementInjectors;
    this.rootElementInjectors = rootElementInjectors;
    this.preBuiltObjects = preBuiltObjects;
    this.componentChildViews = componentChildViews;
  }
  void setLocal(String contextName, value) {
    if (!this.hydrated()) throw new BaseException(
        "Cannot set locals on dehydrated view.");
    if (!MapWrapper.contains(this.proto.variableBindings, contextName)) {
      return;
    }
    var templateName = MapWrapper.get(this.proto.variableBindings, contextName);
    this.locals.set(templateName, value);
  }
  bool hydrated() {
    return isPresent(this.context);
  }
  /**
   * Triggers the event handlers for the element and the directives.
   *
   * This method is intended to be called from directive EventEmitters.
   *
   * @param {string} eventName
   * @param {*} eventObj
   * @param {int} binderIndex
   */
  void triggerEventHandlers(String eventName, eventObj, int binderIndex) {
    var locals = MapWrapper.create();
    MapWrapper.set(locals, "\$event", eventObj);
    this.dispatchEvent(binderIndex, eventName, locals);
  }
  // dispatch to element injector or text nodes based on context
  void notifyOnBinding(BindingRecord b, dynamic currentValue) {
    if (b.isElement()) {
      this.renderer.setElementProperty(
          this.render, b.elementIndex, b.propertyName, currentValue);
    } else {
      // we know it refers to _textNodes.
      this.renderer.setText(this.render, b.elementIndex, currentValue);
    }
  }
  getDirectiveFor(DirectiveIndex directive) {
    var elementInjector = this.elementInjectors[directive.elementIndex];
    return elementInjector.getDirectiveAtIndex(directive.directiveIndex);
  }
  getDetectorFor(DirectiveIndex directive) {
    var childView = this.componentChildViews[directive.elementIndex];
    return isPresent(childView) ? childView.changeDetector : null;
  }
  callAction(num elementIndex, String actionExpression, Object action) {
    this.renderer.callAction(
        this.render, elementIndex, actionExpression, action);
  }
  // implementation of EventDispatcher#dispatchEvent

  // returns false if preventDefault must be applied to the DOM event
  bool dispatchEvent(
      num elementIndex, String eventName, Map<String, dynamic> locals) {
    // Most of the time the event will be fired only when the view is in the live document.

    // However, in a rare circumstance the view might get dehydrated, in between the event

    // queuing up and firing.
    var allowDefaultBehavior = true;
    if (this.hydrated()) {
      var elBinder = this.proto.elementBinders[elementIndex];
      if (isBlank(elBinder.hostListeners)) return allowDefaultBehavior;
      var eventMap = elBinder.hostListeners[eventName];
      if (isBlank(eventMap)) return allowDefaultBehavior;
      MapWrapper.forEach(eventMap, (expr, directiveIndex) {
        var context;
        if (identical(directiveIndex, -1)) {
          context = this.context;
        } else {
          context = this.elementInjectors[elementIndex]
              .getDirectiveAtIndex(directiveIndex);
        }
        var result = expr.eval(context, new Locals(this.locals, locals));
        if (isPresent(result)) {
          allowDefaultBehavior = allowDefaultBehavior && result;
        }
      });
    }
    return allowDefaultBehavior;
  }
}
/**
 *
 */
class AppProtoView {
  List<ElementBinder> elementBinders;
  ProtoChangeDetector protoChangeDetector;
  Map variableBindings;
  Map protoLocals;
  List bindings;
  List variableNames;
  renderApi.RenderProtoViewRef render;
  AppProtoView(renderApi.RenderProtoViewRef render,
      ProtoChangeDetector protoChangeDetector, Map variableBindings,
      Map protoLocals, List variableNames) {
    this.render = render;
    this.elementBinders = [];
    this.variableBindings = variableBindings;
    this.protoLocals = protoLocals;
    this.variableNames = variableNames;
    this.protoChangeDetector = protoChangeDetector;
  }
  ElementBinder bindElement(ElementBinder parent, int distanceToParent,
      ProtoElementInjector protoElementInjector,
      [DirectiveBinding componentDirective = null]) {
    var elBinder = new ElementBinder(this.elementBinders.length, parent,
        distanceToParent, protoElementInjector, componentDirective);
    ListWrapper.push(this.elementBinders, elBinder);
    return elBinder;
  }
  /**
   * Adds an event binding for the last created ElementBinder via bindElement.
   *
   * If the directive index is a positive integer, the event is evaluated in the context of
   * the given directive.
   *
   * If the directive index is -1, the event is evaluated in the context of the enclosing view.
   *
   * @param {string} eventName
   * @param {AST} expression
   * @param {int} directiveIndex The directive index in the binder or -1 when the event is not bound
   *                             to a directive
   */
  void bindEvent(
      List<renderApi.EventBinding> eventBindings, num boundElementIndex,
      [int directiveIndex = -1]) {
    var elBinder = this.elementBinders[boundElementIndex];
    var events = elBinder.hostListeners;
    if (isBlank(events)) {
      events = StringMapWrapper.create();
      elBinder.hostListeners = events;
    }
    for (var i = 0; i < eventBindings.length; i++) {
      var eventBinding = eventBindings[i];
      var eventName = eventBinding.fullName;
      var event = StringMapWrapper.get(events, eventName);
      if (isBlank(event)) {
        event = MapWrapper.create();
        StringMapWrapper.set(events, eventName, event);
      }
      MapWrapper.set(event, directiveIndex, eventBinding.source);
    }
  }
}
