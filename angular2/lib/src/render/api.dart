library angular2.src.render.api;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/src/facade/collection.dart" show List, Map;
import "package:angular2/change_detection.dart" show ASTWithSource;

/**
 * General notes:
 *
 * The methods for creating / destroying views in this API are used in the AppViewHydrator
 * and RenderViewHydrator as well.
 *
 * We are already parsing expressions on the render side:
 * - this makes the ElementBinders more compact
 *   (e.g. no need to distinguish interpolations from regular expressions from literals)
 * - allows to retrieve which properties should be accessed from the event
 *   by looking at the expression
 * - we need the parse at least for the `template` attribute to match
 *   directives in it
 * - render compiler is not on the critical path as
 *   its output will be stored in precompiled templates.
 */
class EventBinding {
  String fullName;
  ASTWithSource source;
  EventBinding(String fullName, ASTWithSource source) {
    this.fullName = fullName;
    this.source = source;
  }
}
class ElementBinder {
  num index;
  num parentIndex;
  num distanceToParent;
  List<DirectiveBinder> directives;
  ProtoViewDto nestedProtoView;
  Map<String, ASTWithSource> propertyBindings;
  Map<String, ASTWithSource> variableBindings;
  // Note: this contains a preprocessed AST

  // that replaced the values that should be extracted from the element

  // with a local name
  List<EventBinding> eventBindings;
  List<ASTWithSource> textBindings;
  Map<String, String> readAttributes;
  ElementBinder({index, parentIndex, distanceToParent, directives,
      nestedProtoView, propertyBindings, variableBindings, eventBindings,
      textBindings, readAttributes}) {
    this.index = index;
    this.parentIndex = parentIndex;
    this.distanceToParent = distanceToParent;
    this.directives = directives;
    this.nestedProtoView = nestedProtoView;
    this.propertyBindings = propertyBindings;
    this.variableBindings = variableBindings;
    this.eventBindings = eventBindings;
    this.textBindings = textBindings;
    this.readAttributes = readAttributes;
  }
}
class DirectiveBinder {
  // Index into the array of directives in the View instance
  num directiveIndex;
  Map<String, ASTWithSource> propertyBindings;
  // Note: this contains a preprocessed AST

  // that replaced the values that should be extracted from the element

  // with a local name
  List<EventBinding> eventBindings;
  Map<String, ASTWithSource> hostPropertyBindings;
  DirectiveBinder(
      {directiveIndex, propertyBindings, eventBindings, hostPropertyBindings}) {
    this.directiveIndex = directiveIndex;
    this.propertyBindings = propertyBindings;
    this.eventBindings = eventBindings;
    this.hostPropertyBindings = hostPropertyBindings;
  }
}
class ProtoViewDto {
  // A view that contains the host element with bound

  // component directive.

  // Contains a view of type #COMPONENT_VIEW_TYPE.
  static get HOST_VIEW_TYPE {
    return 0;
  }
  // The view of the component

  // Can contain 0 to n views of type #EMBEDDED_VIEW_TYPE
  static get COMPONENT_VIEW_TYPE {
    return 1;
  }
  // A view that is embedded into another View via a <template> element

  // inside of a component view
  static get EMBEDDED_VIEW_TYPE {
    return 2;
  }
  RenderProtoViewRef render;
  List<ElementBinder> elementBinders;
  Map<String, String> variableBindings;
  num type;
  ProtoViewDto({render, elementBinders, variableBindings, type}) {
    this.render = render;
    this.elementBinders = elementBinders;
    this.variableBindings = variableBindings;
    this.type = type;
  }
}
class DirectiveMetadata {
  static get DIRECTIVE_TYPE {
    return 0;
  }
  static get COMPONENT_TYPE {
    return 1;
  }
  dynamic id;
  String selector;
  bool compileChildren;
  List<String> events;
  Map<String, String> hostListeners;
  Map<String, String> hostProperties;
  Map<String, String> hostAttributes;
  Map<String, String> hostActions;
  Map<String, String> properties;
  List<String> readAttributes;
  num type;
  bool callOnDestroy;
  bool callOnChange;
  bool callOnAllChangesDone;
  String changeDetection;
  DirectiveMetadata({id, selector, compileChildren, events, hostListeners,
      hostProperties, hostAttributes, hostActions, properties, readAttributes,
      type, callOnDestroy, callOnChange, callOnAllChangesDone,
      changeDetection}) {
    this.id = id;
    this.selector = selector;
    this.compileChildren = isPresent(compileChildren) ? compileChildren : true;
    this.events = events;
    this.hostListeners = hostListeners;
    this.hostProperties = hostProperties;
    this.hostAttributes = hostAttributes;
    this.hostActions = hostActions;
    this.properties = properties;
    this.readAttributes = readAttributes;
    this.type = type;
    this.callOnDestroy = callOnDestroy;
    this.callOnChange = callOnChange;
    this.callOnAllChangesDone = callOnAllChangesDone;
    this.changeDetection = changeDetection;
  }
}
// An opaque reference to a DomProtoView
class RenderProtoViewRef {}
// An opaque reference to a DomView
class RenderViewRef {}
class ViewDefinition {
  String componentId;
  String absUrl;
  String template;
  List<DirectiveMetadata> directives;
  ViewDefinition({componentId, absUrl, template, directives}) {
    this.componentId = componentId;
    this.absUrl = absUrl;
    this.template = template;
    this.directives = directives;
  }
}
class RenderCompiler {
  /**
   * Creats a ProtoViewDto that contains a single nested component with the given componentId.
   */
  Future<ProtoViewDto> compileHost(DirectiveMetadata directiveMetadata) {
    return null;
  }
  /**
   * Compiles a single DomProtoView. Non recursive so that
   * we don't need to serialize all possible components over the wire,
   * but only the needed ones based on previous calls.
   */
  Future<ProtoViewDto> compile(ViewDefinition template) {
    return null;
  }
}
class Renderer {
  /**
   * Creates a root host view that includes the given element.
   * @param {RenderProtoViewRef} hostProtoViewRef a RenderProtoViewRef of type
   * ProtoViewDto.HOST_VIEW_TYPE
   * @param {any} hostElementSelector css selector for the host element (will be queried against the
   * main document)
   * @return {RenderViewRef} the created view
   */
  RenderViewRef createRootHostView(
      RenderProtoViewRef hostProtoViewRef, String hostElementSelector) {
    return null;
  }
  /**
   * Detaches a free host view's element from the DOM.
   */
  detachFreeHostView(
      RenderViewRef parentHostViewRef, RenderViewRef hostViewRef) {}
  /**
   * Creates a regular view out of the given ProtoView
   */
  RenderViewRef createView(RenderProtoViewRef protoViewRef) {
    return null;
  }
  /**
   * Destroys the given view after it has been dehydrated and detached
   */
  destroyView(RenderViewRef viewRef) {}
  /**
   * Attaches a componentView into the given hostView at the given element
   */
  attachComponentView(RenderViewRef hostViewRef, num elementIndex,
      RenderViewRef componentViewRef) {}
  /**
   * Detaches a componentView into the given hostView at the given element
   */
  detachComponentView(RenderViewRef hostViewRef, num boundElementIndex,
      RenderViewRef componentViewRef) {}
  /**
   * Attaches a view into a ViewContainer (in the given parentView at the given element) at the
   * given index.
   */
  attachViewInContainer(RenderViewRef parentViewRef, num boundElementIndex,
      num atIndex, RenderViewRef viewRef) {}
  /**
   * Detaches a view into a ViewContainer (in the given parentView at the given element) at the
   * given index.
   */

  // TODO(tbosch): this should return a promise as it can be animated!
  detachViewInContainer(RenderViewRef parentViewRef, num boundElementIndex,
      num atIndex, RenderViewRef viewRef) {}
  /**
   * Hydrates a view after it has been attached. Hydration/dehydration is used for reusing views
   * inside of the view pool.
   */
  hydrateView(RenderViewRef viewRef) {}
  /**
   * Dehydrates a view after it has been attached. Hydration/dehydration is used for reusing views
   * inside of the view pool.
   */
  dehydrateView(RenderViewRef viewRef) {}
  /**
   * Sets a property on an element.
   * Note: This will fail if the property was not mentioned previously as a host property
   * in the ProtoView
   */
  setElementProperty(RenderViewRef viewRef, num elementIndex,
      String propertyName, dynamic propertyValue) {}
  /**
   * Calls an action.
   * Note: This will fail if the action was not mentioned previously as a host action
   * in the ProtoView
   */
  callAction(RenderViewRef viewRef, num elementIndex, String actionExpression,
      dynamic actionArgs) {}
  /**
   * Sets the value of a text node.
   */
  setText(RenderViewRef viewRef, num textNodeIndex, String text) {}
  /**
   * Sets the dispatcher for all events of the given view
   */
  setEventDispatcher(RenderViewRef viewRef, EventDispatcher dispatcher) {}
}
/**
 * A dispatcher for all events happening in a view.
 */
abstract class EventDispatcher {
  /**
   * Called when an event was triggered for a on-* attribute on an element.
   * @param {Map<string, any>} locals Locals to be used to evaluate the
   *   event expressions
   */
  dispatchEvent(
      num elementIndex, String eventName, Map<String, dynamic> locals);
}
