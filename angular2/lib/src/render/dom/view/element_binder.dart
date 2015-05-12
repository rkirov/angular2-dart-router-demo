library angular2.src.render.dom.view.element_binder;

import "package:angular2/change_detection.dart" show AST;
import "package:angular2/src/reflection/types.dart" show SetterFn;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "proto_view.dart" as protoViewModule;

class ElementBinder {
  String contentTagSelector;
  List<num> textNodeIndices;
  protoViewModule.DomProtoView nestedProtoView;
  AST eventLocals;
  List<Event> localEvents;
  List<Event> globalEvents;
  String componentId;
  num parentIndex;
  num distanceToParent;
  Map<String, SetterFn> propertySetters;
  Map<String, AST> hostActions;
  ElementBinder({textNodeIndices, contentTagSelector, nestedProtoView,
      componentId, eventLocals, localEvents, globalEvents, hostActions,
      parentIndex, distanceToParent, propertySetters}) {
    this.textNodeIndices = textNodeIndices;
    this.contentTagSelector = contentTagSelector;
    this.nestedProtoView = nestedProtoView;
    this.componentId = componentId;
    this.eventLocals = eventLocals;
    this.localEvents = localEvents;
    this.globalEvents = globalEvents;
    this.hostActions = hostActions;
    this.parentIndex = parentIndex;
    this.distanceToParent = distanceToParent;
    this.propertySetters = propertySetters;
  }
}
class Event {
  String name;
  String target;
  String fullName;
  Event(String name, String target, String fullName) {
    this.name = name;
    this.target = target;
    this.fullName = fullName;
  }
}
class HostAction {
  String actionName;
  String actionExpression;
  AST expression;
  HostAction(String actionName, String actionExpression, AST expression) {
    this.actionName = actionName;
    this.actionExpression = actionExpression;
    this.expression = expression;
  }
}
