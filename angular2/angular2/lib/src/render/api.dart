library angular2.src.render.api;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/facade/async.dart" show Future;
import "package:angular2/src/facade/collection.dart" show List, Map;
import "package:angular2/change_detection.dart"
    show
        ASTWithSource; /**
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
  Map<String, ASTWithSource> variableBindings; // Note: this contains a preprocessed AST
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
  dynamic directiveIndex;
  Map<String, ASTWithSource> propertyBindings; // Note: this contains a preprocessed AST
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
  } // The view of the component
  // Can contain 0 to n views of type #EMBEDDED_VIEW_TYPE
  static get COMPONENT_VIEW_TYPE {
    return 1;
  } // A view that is embedded into another View via a <template> element
  // inside of a component view
  static get EMBEDDED_VIEW_TYPE {
    return 1;
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
  Map<String, String> hostListeners;
  Map<String, String> hostProperties;
  Map<String, String> properties;
  List<String> readAttributes;
  num type;
  DirectiveMetadata({id, selector, compileChildren, hostListeners,
      hostProperties, properties, readAttributes, type}) {
    this.id = id;
    this.selector = selector;
    this.compileChildren = isPresent(compileChildren) ? compileChildren : true;
    this.hostListeners = hostListeners;
    this.hostProperties = hostProperties;
    this.properties = properties;
    this.readAttributes = readAttributes;
    this.type = type;
  }
} // An opaque reference to a RenderProtoView
class RenderProtoViewRef {} // An opaque reference to a RenderView
class RenderViewRef {}
class RenderViewContainerRef {
  RenderViewRef view;
  num elementIndex;
  RenderViewContainerRef(RenderViewRef view, num elementIndex) {
    this.view = view;
    this.elementIndex = elementIndex;
  }
}
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
class Renderer {
  /**
   * Creats a ProtoViewDto that contains a single nested component with the given componentId.
   */
  Future<ProtoViewDto> createHostProtoView(componentId) {
    return null;
  } /**
   * Creats a ProtoViewDto for a component that will use an imperative View using the given
   * renderer.
   * Note: Rigth now, the renderer argument is ignored, but will be used in the future to define
   * a custom handler.
   */
  Future<ProtoViewDto> createImperativeComponentProtoView(rendererId) {
    return null;
  } /**
   * Compiles a single RenderProtoView. Non recursive so that
   * we don't need to serialize all possible components over the wire,
   * but only the needed ones based on previous calls.
   */
  Future<ProtoViewDto> compile(ViewDefinition template) {
    return null;
  } /**
   * Sets the preset nested components,
   * which will be instantiated when this protoView is instantiated.
   * Note: We can't create new ProtoViewRefs here as we need to support cycles / recursive components.
   * @param {List<RenderProtoViewRef>} protoViewRefs
   *    RenderProtoView for every element with a component in this protoView or in a view container's protoView
   */
  mergeChildComponentProtoViews(RenderProtoViewRef protoViewRef,
      List<RenderProtoViewRef> componentProtoViewRefs) {
    return null;
  } /**
   * Creates a view and inserts it into a ViewContainer.
   * @param {RenderViewContainerRef} viewContainerRef
   * @param {RenderProtoViewRef} protoViewRef A RenderProtoViewRef of type ProtoViewDto.HOST_VIEW_TYPE or ProtoViewDto.EMBEDDED_VIEW_TYPE
   * @param {number} atIndex
   * @return {List<RenderViewRef>} the view and all of its nested child component views
   */
  List<RenderViewRef> createViewInContainer(RenderViewContainerRef vcRef,
      num atIndex, RenderProtoViewRef protoViewRef) {
    return null;
  } /**
   * Destroys the view in the given ViewContainer
   */
  void destroyViewInContainer(RenderViewContainerRef vcRef, num atIndex) {
  } /**
   * Inserts a detached view into a viewContainer.
   */
  void insertViewIntoContainer(
      RenderViewContainerRef vcRef, num atIndex, RenderViewRef view) {
  } /**
   * Detaches a view from a container so that it can be inserted later on
   */
  void detachViewFromContainer(RenderViewContainerRef vcRef, num atIndex) {
  } /**
   * Creates a view and
   * installs it as a shadow view for an element.
   *
   * Note: only allowed if there is a dynamic component directive at this place.
   * @param {RenderViewRef} hostView
   * @param {number} elementIndex
   * @param {RenderProtoViewRef} componentProtoViewRef A RenderProtoViewRef of type ProtoViewDto.COMPONENT_VIEW_TYPE
   * @return {List<RenderViewRef>} the view and all of its nested child component views
   */
  List<RenderViewRef> createDynamicComponentView(RenderViewRef hostViewRef,
      num elementIndex, RenderProtoViewRef componentProtoViewRef) {
    return null;
  } /**
   * Destroys the component view at the given index
   *
   * Note: only allowed if there is a dynamic component directive at this place.
   */
  void destroyDynamicComponentView(
      RenderViewRef hostViewRef, num elementIndex) {
  } /**
   * Creates a host view that includes the given element.
   * @param {RenderViewRef} parentViewRef (might be null)
   * @param {any} hostElementSelector element or css selector for the host element
   * @param {RenderProtoViewRef} hostProtoView a RenderProtoViewRef of type ProtoViewDto.HOST_VIEW_TYPE
   * @return {List<RenderViewRef>} the view and all of its nested child component views
   */
  List<RenderViewRef> createInPlaceHostView(RenderViewRef parentViewRef,
      hostElementSelector, RenderProtoViewRef hostProtoViewRef) {
    return null;
  } /**
   * Destroys the given host view in the given parent view.
   */
  void destroyInPlaceHostView(
      RenderViewRef parentViewRef, RenderViewRef hostViewRef) {
  } /**
   * Sets a property on an element.
   * Note: This will fail if the property was not mentioned previously as a host property
   * in the View.
   */
  void setElementProperty(RenderViewRef view, num elementIndex,
      String propertyName, dynamic propertyValue) {
  } /**
   * This will set the value for a text node.
   * Note: This needs to be separate from setElementProperty as we don't have ElementBinders
   * for text nodes in the RenderProtoView either.
   */
  void setText(RenderViewRef view, num textNodeIndex, String text) {
  } /**
   * Sets the dispatcher for all events that have been defined in the template or in directives
   * in the given view.
   */
  void setEventDispatcher(RenderViewRef viewRef, dynamic dispatcher) {
  } /**
   * To be called at the end of the VmTurn so the API can buffer calls
   */
  void flush() {}
} /**
 * A dispatcher for all events happening in a view.
 */
class EventDispatcher {
  /**
   * Called when an event was triggered for a on-* attribute on an element.
   * @param {Map<string, any>} locals Locals to be used to evaluate the
   *   event expressions
   */
  void dispatchEvent(
      num elementIndex, String eventName, Map<String, dynamic> locals) {}
}
