library angular2.src.core.compiler.view_ref;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "view.dart" as viewModule;
import "package:angular2/src/render/api.dart" show RenderViewRef;

// This is a workaround for privacy in Dart as we don't have library parts
internalView(ViewRef viewRef) {
  return viewRef._view;
}
// This is a workaround for privacy in Dart as we don't have library parts
internalProtoView(ProtoViewRef protoViewRef) {
  return isPresent(protoViewRef) ? protoViewRef._protoView : null;
}
/**
 * @exportedAs angular2/view
 */
class ViewRef {
  viewModule.AppView _view;
  ViewRef(viewModule.AppView view) {
    this._view = view;
  }
  RenderViewRef get render {
    return this._view.render;
  }
  setLocal(String contextName, dynamic value) {
    this._view.setLocal(contextName, value);
  }
}
/**
 * @exportedAs angular2/view
 */
class ProtoViewRef {
  viewModule.AppProtoView _protoView;
  ProtoViewRef(protoView) {
    this._protoView = protoView;
  }
}
