library angular2.src.core.compiler.proto_view_factory;

import "package:angular2/di.dart" show Injectable;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, MapWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent, isBlank;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/change_detection.dart"
    show
        ChangeDetection,
        DirectiveIndex,
        BindingRecord,
        DirectiveRecord,
        ProtoChangeDetector,
        DEFAULT,
        ChangeDetectorDefinition;
import "package:angular2/src/render/api.dart" as renderApi;
import "view.dart" show AppProtoView;
import "element_binder.dart" show ElementBinder;
import "element_injector.dart" show ProtoElementInjector, DirectiveBinding;

class BindingRecordsCreator {
  Map<num, DirectiveRecord> _directiveRecordsMap;
  num _textNodeIndex;
  BindingRecordsCreator() {
    this._directiveRecordsMap = MapWrapper.create();
    this._textNodeIndex = 0;
  }
  List<BindingRecord> getBindingRecords(
      List<renderApi.ElementBinder> elementBinders,
      List<renderApi.DirectiveMetadata> allDirectiveMetadatas) {
    var bindings = [];
    for (var boundElementIndex = 0;
        boundElementIndex < elementBinders.length;
        boundElementIndex++) {
      var renderElementBinder = elementBinders[boundElementIndex];
      this._createTextNodeRecords(bindings, renderElementBinder);
      this._createElementPropertyRecords(
          bindings, boundElementIndex, renderElementBinder);
      this._createDirectiveRecords(bindings, boundElementIndex,
          renderElementBinder.directives, allDirectiveMetadatas);
    }
    return bindings;
  }
  List<DirectiveRecord> getDirectiveRecords(
      List<renderApi.ElementBinder> elementBinders,
      List<renderApi.DirectiveMetadata> allDirectiveMetadatas) {
    var directiveRecords = [];
    for (var elementIndex = 0;
        elementIndex < elementBinders.length;
        ++elementIndex) {
      var dirs = elementBinders[elementIndex].directives;
      for (var dirIndex = 0; dirIndex < dirs.length; ++dirIndex) {
        ListWrapper.push(directiveRecords, this._getDirectiveRecord(
            elementIndex, dirIndex,
            allDirectiveMetadatas[dirs[dirIndex].directiveIndex]));
      }
    }
    return directiveRecords;
  }
  _createTextNodeRecords(List<BindingRecord> bindings,
      renderApi.ElementBinder renderElementBinder) {
    if (isBlank(renderElementBinder.textBindings)) return;
    ListWrapper.forEach(renderElementBinder.textBindings, (b) {
      ListWrapper.push(
          bindings, BindingRecord.createForTextNode(b, this._textNodeIndex++));
    });
  }
  _createElementPropertyRecords(List<BindingRecord> bindings,
      num boundElementIndex, renderApi.ElementBinder renderElementBinder) {
    MapWrapper.forEach(renderElementBinder.propertyBindings,
        (astWithSource, propertyName) {
      ListWrapper.push(bindings, BindingRecord.createForElement(
          astWithSource, boundElementIndex, propertyName));
    });
  }
  _createDirectiveRecords(List<BindingRecord> bindings, num boundElementIndex,
      List<renderApi.DirectiveBinder> directiveBinders,
      List<renderApi.DirectiveMetadata> allDirectiveMetadatas) {
    for (var i = 0; i < directiveBinders.length; i++) {
      var directiveBinder = directiveBinders[i];
      var directiveMetadata =
          allDirectiveMetadatas[directiveBinder.directiveIndex];
      // directive properties
      MapWrapper.forEach(directiveBinder.propertyBindings,
          (astWithSource, propertyName) {
        // TODO: these setters should eventually be created by change detection, to make

        // it monomorphic!
        var setter = reflector.setter(propertyName);
        var directiveRecord =
            this._getDirectiveRecord(boundElementIndex, i, directiveMetadata);
        ListWrapper.push(bindings, BindingRecord.createForDirective(
            astWithSource, propertyName, setter, directiveRecord));
      });
      // host properties
      MapWrapper.forEach(directiveBinder.hostPropertyBindings,
          (astWithSource, propertyName) {
        var dirIndex = new DirectiveIndex(boundElementIndex, i);
        ListWrapper.push(bindings, BindingRecord.createForHostProperty(
            dirIndex, astWithSource, propertyName));
      });
    }
  }
  DirectiveRecord _getDirectiveRecord(num boundElementIndex, num directiveIndex,
      renderApi.DirectiveMetadata directiveMetadata) {
    var id = boundElementIndex * 100 + directiveIndex;
    if (!MapWrapper.contains(this._directiveRecordsMap, id)) {
      var changeDetection = directiveMetadata.changeDetection;
      MapWrapper.set(this._directiveRecordsMap, id, new DirectiveRecord(
          new DirectiveIndex(boundElementIndex, directiveIndex),
          directiveMetadata.callOnAllChangesDone,
          directiveMetadata.callOnChange, changeDetection));
    }
    return MapWrapper.get(this._directiveRecordsMap, id);
  }
}
@Injectable()
class ProtoViewFactory {
  ChangeDetection _changeDetection;
  ProtoViewFactory(ChangeDetection changeDetection) {
    this._changeDetection = changeDetection;
  }
  List<AppProtoView> createAppProtoViews(DirectiveBinding hostComponentBinding,
      renderApi.ProtoViewDto rootRenderProtoView,
      List<DirectiveBinding> allDirectives) {
    var allRenderDirectiveMetadata = ListWrapper.map(
        allDirectives, (directiveBinding) => directiveBinding.metadata);
    var nestedPvsWithIndex = _collectNestedProtoViews(rootRenderProtoView);
    var nestedPvVariableBindings =
        _collectNestedProtoViewsVariableBindings(nestedPvsWithIndex);
    var nestedPvVariableNames = _collectNestedProtoViewsVariableNames(
        nestedPvsWithIndex, nestedPvVariableBindings);
    var changeDetectorDefs = _getChangeDetectorDefinitions(
        hostComponentBinding.metadata, nestedPvsWithIndex,
        nestedPvVariableNames, allRenderDirectiveMetadata);
    var protoChangeDetectors = ListWrapper.map(changeDetectorDefs,
        (changeDetectorDef) =>
            this._changeDetection.createProtoChangeDetector(changeDetectorDef));
    var appProtoViews = ListWrapper.createFixedSize(nestedPvsWithIndex.length);
    ListWrapper.forEach(nestedPvsWithIndex, (pvWithIndex) {
      var appProtoView = _createAppProtoView(pvWithIndex.renderProtoView,
          protoChangeDetectors[pvWithIndex.index],
          nestedPvVariableBindings[pvWithIndex.index], allDirectives);
      if (isPresent(pvWithIndex.parentIndex)) {
        var parentView = appProtoViews[pvWithIndex.parentIndex];
        parentView.elementBinders[
            pvWithIndex.boundElementIndex].nestedProtoView = appProtoView;
      }
      appProtoViews[pvWithIndex.index] = appProtoView;
    });
    return appProtoViews;
  }
}
/**
 * Returns the data needed to create ChangeDetectors
 * for the given ProtoView and all nested ProtoViews.
 */
List<ChangeDetectorDefinition> getChangeDetectorDefinitions(
    renderApi.DirectiveMetadata hostComponentMetadata,
    renderApi.ProtoViewDto rootRenderProtoView,
    List<renderApi.DirectiveMetadata> allRenderDirectiveMetadata) {
  var nestedPvsWithIndex = _collectNestedProtoViews(rootRenderProtoView);
  var nestedPvVariableBindings =
      _collectNestedProtoViewsVariableBindings(nestedPvsWithIndex);
  var nestedPvVariableNames = _collectNestedProtoViewsVariableNames(
      nestedPvsWithIndex, nestedPvVariableBindings);
  return _getChangeDetectorDefinitions(hostComponentMetadata,
      nestedPvsWithIndex, nestedPvVariableNames, allRenderDirectiveMetadata);
}
List<RenderProtoViewWithIndex> _collectNestedProtoViews(
    renderApi.ProtoViewDto renderProtoView, [num parentIndex = null,
    boundElementIndex = null, List<RenderProtoViewWithIndex> result = null]) {
  if (isBlank(result)) {
    result = [];
  }
  ListWrapper.push(result, new RenderProtoViewWithIndex(
      renderProtoView, result.length, parentIndex, boundElementIndex));
  var currentIndex = result.length - 1;
  var childBoundElementIndex = 0;
  ListWrapper.forEach(renderProtoView.elementBinders, (elementBinder) {
    if (isPresent(elementBinder.nestedProtoView)) {
      _collectNestedProtoViews(elementBinder.nestedProtoView, currentIndex,
          childBoundElementIndex, result);
    }
    childBoundElementIndex++;
  });
  return result;
}
List<ChangeDetectorDefinition> _getChangeDetectorDefinitions(
    renderApi.DirectiveMetadata hostComponentMetadata,
    List<RenderProtoViewWithIndex> nestedPvsWithIndex,
    List<List<String>> nestedPvVariableNames,
    List<renderApi.DirectiveMetadata> allRenderDirectiveMetadata) {
  return ListWrapper.map(nestedPvsWithIndex, (pvWithIndex) {
    var elementBinders = pvWithIndex.renderProtoView.elementBinders;
    var bindingRecordsCreator = new BindingRecordsCreator();
    var bindingRecords = bindingRecordsCreator.getBindingRecords(
        elementBinders, allRenderDirectiveMetadata);
    var directiveRecords = bindingRecordsCreator.getDirectiveRecords(
        elementBinders, allRenderDirectiveMetadata);
    var strategyName = DEFAULT;
    var typeString;
    if (identical(pvWithIndex.renderProtoView.type,
        renderApi.ProtoViewDto.COMPONENT_VIEW_TYPE)) {
      strategyName = hostComponentMetadata.changeDetection;
      typeString = "comp";
    } else if (identical(pvWithIndex.renderProtoView.type,
        renderApi.ProtoViewDto.HOST_VIEW_TYPE)) {
      typeString = "host";
    } else {
      typeString = "embedded";
    }
    var id =
        '''${ hostComponentMetadata . id}_${ typeString}_${ pvWithIndex . index}''';
    var variableNames = nestedPvVariableNames[pvWithIndex.index];
    return new ChangeDetectorDefinition(
        id, strategyName, variableNames, bindingRecords, directiveRecords);
  });
}
AppProtoView _createAppProtoView(renderApi.ProtoViewDto renderProtoView,
    ProtoChangeDetector protoChangeDetector,
    Map<String, String> variableBindings,
    List<DirectiveBinding> allDirectives) {
  var elementBinders = renderProtoView.elementBinders;
  var protoView = new AppProtoView(
      renderProtoView.render, protoChangeDetector, variableBindings);
  // TODO: vsavkin refactor to pass element binders into proto view
  _createElementBinders(protoView, elementBinders, allDirectives);
  _bindDirectiveEvents(protoView, elementBinders);
  return protoView;
}
List<Map<String, String>> _collectNestedProtoViewsVariableBindings(
    List<RenderProtoViewWithIndex> nestedPvsWithIndex) {
  return ListWrapper.map(nestedPvsWithIndex, (pvWithIndex) {
    return _createVariableBindings(pvWithIndex.renderProtoView);
  });
}
Map<String, String> _createVariableBindings(renderProtoView) {
  var variableBindings = MapWrapper.create();
  MapWrapper.forEach(renderProtoView.variableBindings, (mappedName, varName) {
    MapWrapper.set(variableBindings, varName, mappedName);
  });
  ListWrapper.forEach(renderProtoView.elementBinders, (binder) {
    MapWrapper.forEach(binder.variableBindings, (mappedName, varName) {
      MapWrapper.set(variableBindings, varName, mappedName);
    });
  });
  return variableBindings;
}
List<List<String>> _collectNestedProtoViewsVariableNames(
    List<RenderProtoViewWithIndex> nestedPvsWithIndex,
    List<Map<String, String>> nestedPvVariableBindings) {
  var nestedPvVariableNames =
      ListWrapper.createFixedSize(nestedPvsWithIndex.length);
  ListWrapper.forEach(nestedPvsWithIndex, (pvWithIndex) {
    var parentVariableNames = isPresent(pvWithIndex.parentIndex)
        ? nestedPvVariableNames[pvWithIndex.parentIndex]
        : null;
    nestedPvVariableNames[pvWithIndex.index] = _createVariableNames(
        parentVariableNames, nestedPvVariableBindings[pvWithIndex.index]);
  });
  return nestedPvVariableNames;
}
List<String> _createVariableNames(parentVariableNames, variableBindings) {
  var variableNames = isPresent(parentVariableNames)
      ? ListWrapper.clone(parentVariableNames)
      : [];
  MapWrapper.forEach(variableBindings, (local, v) {
    ListWrapper.push(variableNames, local);
  });
  return variableNames;
}
_createElementBinders(protoView, elementBinders, allDirectiveBindings) {
  for (var i = 0; i < elementBinders.length; i++) {
    var renderElementBinder = elementBinders[i];
    var dirs = elementBinders[i].directives;
    var parentPeiWithDistance = _findParentProtoElementInjectorWithDistance(
        i, protoView.elementBinders, elementBinders);
    var directiveBindings = ListWrapper.map(
        dirs, (dir) => allDirectiveBindings[dir.directiveIndex]);
    var componentDirectiveBinding = null;
    if (directiveBindings.length > 0) {
      if (identical(directiveBindings[0].metadata.type,
          renderApi.DirectiveMetadata.COMPONENT_TYPE)) {
        componentDirectiveBinding = directiveBindings[0];
      }
    }
    var protoElementInjector = _createProtoElementInjector(i,
        parentPeiWithDistance, renderElementBinder, componentDirectiveBinding,
        directiveBindings);
    _createElementBinder(protoView, i, renderElementBinder,
        protoElementInjector, componentDirectiveBinding);
  }
}
ParentProtoElementInjectorWithDistance _findParentProtoElementInjectorWithDistance(
    binderIndex, elementBinders, renderElementBinders) {
  var distance = 0;
  do {
    var renderElementBinder = renderElementBinders[binderIndex];
    binderIndex = renderElementBinder.parentIndex;
    if (!identical(binderIndex, -1)) {
      distance += renderElementBinder.distanceToParent;
      var elementBinder = elementBinders[binderIndex];
      if (isPresent(elementBinder.protoElementInjector)) {
        return new ParentProtoElementInjectorWithDistance(
            elementBinder.protoElementInjector, distance);
      }
    }
  } while (!identical(binderIndex, -1));
  return new ParentProtoElementInjectorWithDistance(null, -1);
}
_createProtoElementInjector(binderIndex, parentPeiWithDistance,
    renderElementBinder, componentDirectiveBinding, directiveBindings) {
  var protoElementInjector = null;
  // Create a protoElementInjector for any element that either has bindings *or* has one

  // or more var- defined. Elements with a var- defined need a their own element injector

  // so that, when hydrating, $implicit can be set to the element.
  var hasVariables = MapWrapper.size(renderElementBinder.variableBindings) > 0;
  if (directiveBindings.length > 0 || hasVariables) {
    protoElementInjector = ProtoElementInjector.create(
        parentPeiWithDistance.protoElementInjector, binderIndex,
        directiveBindings, isPresent(componentDirectiveBinding),
        parentPeiWithDistance.distance);
    protoElementInjector.attributes = renderElementBinder.readAttributes;
    if (hasVariables) {
      protoElementInjector.exportComponent =
          isPresent(componentDirectiveBinding);
      protoElementInjector.exportElement = isBlank(componentDirectiveBinding);
      // experiment
      var exportImplicitName =
          MapWrapper.get(renderElementBinder.variableBindings, "\$implicit");
      if (isPresent(exportImplicitName)) {
        protoElementInjector.exportImplicitName = exportImplicitName;
      }
    }
  }
  return protoElementInjector;
}
ElementBinder _createElementBinder(protoView, boundElementIndex,
    renderElementBinder, protoElementInjector, componentDirectiveBinding) {
  var parent = null;
  if (!identical(renderElementBinder.parentIndex, -1)) {
    parent = protoView.elementBinders[renderElementBinder.parentIndex];
  }
  var elBinder = protoView.bindElement(parent,
      renderElementBinder.distanceToParent, protoElementInjector,
      componentDirectiveBinding);
  protoView.bindEvent(renderElementBinder.eventBindings, boundElementIndex, -1);
  // variables

  // The view's locals needs to have a full set of variable names at construction time

  // in order to prevent new variables from being set later in the lifecycle. Since we don't want

  // to actually create variable bindings for the $implicit bindings, add to the

  // protoLocals manually.
  MapWrapper.forEach(renderElementBinder.variableBindings,
      (mappedName, varName) {
    MapWrapper.set(protoView.protoLocals, mappedName, null);
  });
  return elBinder;
}
_bindDirectiveEvents(protoView, List<renderApi.ElementBinder> elementBinders) {
  for (var boundElementIndex = 0;
      boundElementIndex < elementBinders.length;
      ++boundElementIndex) {
    var dirs = elementBinders[boundElementIndex].directives;
    for (var i = 0; i < dirs.length; i++) {
      var directiveBinder = dirs[i];
      // directive events
      protoView.bindEvent(directiveBinder.eventBindings, boundElementIndex, i);
    }
  }
}
class RenderProtoViewWithIndex {
  renderApi.ProtoViewDto renderProtoView;
  num index;
  num parentIndex;
  num boundElementIndex;
  RenderProtoViewWithIndex(renderApi.ProtoViewDto renderProtoView, num index,
      num parentIndex, num boundElementIndex) {
    this.renderProtoView = renderProtoView;
    this.index = index;
    this.parentIndex = parentIndex;
    this.boundElementIndex = boundElementIndex;
  }
}
class ParentProtoElementInjectorWithDistance {
  ProtoElementInjector protoElementInjector;
  num distance;
  ParentProtoElementInjectorWithDistance(
      ProtoElementInjector protoElementInjector, num distance) {
    this.protoElementInjector = protoElementInjector;
    this.distance = distance;
  }
}
