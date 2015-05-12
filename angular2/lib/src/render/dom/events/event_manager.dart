library angular2.src.render.dom.events.event_manager;

import "package:angular2/src/facade/lang.dart"
    show isBlank, BaseException, isPresent, StringWrapper;
import "package:angular2/src/dom/dom_adapter.dart" show DOM;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, MapWrapper;
import "package:angular2/src/core/zone/ng_zone.dart" show NgZone;

var BUBBLE_SYMBOL = "^";
class EventManager {
  List<EventManagerPlugin> _plugins;
  NgZone _zone;
  EventManager(List<EventManagerPlugin> plugins, NgZone zone) {
    this._zone = zone;
    this._plugins = plugins;
    for (var i = 0; i < plugins.length; i++) {
      plugins[i].manager = this;
    }
  }
  addEventListener(element, String eventName, Function handler) {
    var withoutBubbleSymbol = this._removeBubbleSymbol(eventName);
    var plugin = this._findPluginFor(withoutBubbleSymbol);
    plugin.addEventListener(element, withoutBubbleSymbol, handler,
        withoutBubbleSymbol != eventName);
  }
  Function addGlobalEventListener(
      String target, String eventName, Function handler) {
    var withoutBubbleSymbol = this._removeBubbleSymbol(eventName);
    var plugin = this._findPluginFor(withoutBubbleSymbol);
    return plugin.addGlobalEventListener(
        target, withoutBubbleSymbol, handler, withoutBubbleSymbol != eventName);
  }
  NgZone getZone() {
    return this._zone;
  }
  EventManagerPlugin _findPluginFor(String eventName) {
    var plugins = this._plugins;
    for (var i = 0; i < plugins.length; i++) {
      var plugin = plugins[i];
      if (plugin.supports(eventName)) {
        return plugin;
      }
    }
    throw new BaseException(
        '''No event manager plugin found for event ${ eventName}''');
  }
  String _removeBubbleSymbol(String eventName) {
    return eventName[0] == BUBBLE_SYMBOL
        ? StringWrapper.substring(eventName, 1)
        : eventName;
  }
}
class EventManagerPlugin {
  EventManager manager;
  // We are assuming here that all plugins support bubbled and non-bubbled events.

  // That is equivalent to having supporting $event.target

  // The bubbling flag (currently ^) is stripped before calling the supports and

  // addEventListener methods.
  bool supports(String eventName) {
    return false;
  }
  addEventListener(
      element, String eventName, Function handler, bool shouldSupportBubble) {
    throw "not implemented";
  }
  Function addGlobalEventListener(
      element, String eventName, Function handler, bool shouldSupportBubble) {
    throw "not implemented";
  }
}
class DomEventsPlugin extends EventManagerPlugin {
  EventManager manager;
  // This plugin should come last in the list of plugins, because it accepts all

  // events.
  bool supports(String eventName) {
    return true;
  }
  addEventListener(
      element, String eventName, Function handler, bool shouldSupportBubble) {
    var outsideHandler = this._getOutsideHandler(
        shouldSupportBubble, element, handler, this.manager._zone);
    this.manager._zone.runOutsideAngular(() {
      DOM.on(element, eventName, outsideHandler);
    });
  }
  Function addGlobalEventListener(String target, String eventName,
      Function handler, bool shouldSupportBubble) {
    var element = DOM.getGlobalEventTarget(target);
    var outsideHandler = this._getOutsideHandler(
        shouldSupportBubble, element, handler, this.manager._zone);
    return this.manager._zone.runOutsideAngular(() {
      return DOM.onAndCancel(element, eventName, outsideHandler);
    });
  }
  _getOutsideHandler(
      bool shouldSupportBubble, element, Function handler, NgZone zone) {
    return shouldSupportBubble
        ? DomEventsPlugin.bubbleCallback(element, handler, zone)
        : DomEventsPlugin.sameElementCallback(element, handler, zone);
  }
  static sameElementCallback(element, handler, zone) {
    return (event) {
      if (identical(event.target, element)) {
        zone.run(() => handler(event));
      }
    };
  }
  static bubbleCallback(element, handler, zone) {
    return (event) => zone.run(() => handler(event));
  }
}
