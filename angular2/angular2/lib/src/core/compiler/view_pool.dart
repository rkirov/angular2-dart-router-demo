library angular2.src.core.compiler.view_pool;

import "package:angular2/src/di/annotations_impl.dart" show Inject;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, Map, List;
import "package:angular2/src/facade/lang.dart" show isPresent, isBlank;
import "view.dart"
    as viewModule; // TODO(tbosch): Make this an OpaqueToken as soon as our transpiler supports this!

const APP_VIEW_POOL_CAPACITY = "AppViewPool.viewPoolCapacity";
class AppViewPool {
  num _poolCapacityPerProtoView;
  Map<viewModule.AppProtoView, List<viewModule.AppView>> _pooledViewsPerProtoView;
  AppViewPool(@Inject(APP_VIEW_POOL_CAPACITY) poolCapacityPerProtoView) {
    this._poolCapacityPerProtoView = poolCapacityPerProtoView;
    this._pooledViewsPerProtoView = MapWrapper.create();
  }
  viewModule.AppView getView(viewModule.AppProtoView protoView) {
    var pooledViews = MapWrapper.get(this._pooledViewsPerProtoView, protoView);
    if (isPresent(pooledViews) && pooledViews.length > 0) {
      return ListWrapper.removeLast(pooledViews);
    }
    return null;
  }
  returnView(viewModule.AppView view) {
    var protoView = view.proto;
    var pooledViews = MapWrapper.get(this._pooledViewsPerProtoView, protoView);
    if (isBlank(pooledViews)) {
      pooledViews = [];
      MapWrapper.set(this._pooledViewsPerProtoView, protoView, pooledViews);
    }
    if (pooledViews.length < this._poolCapacityPerProtoView) {
      ListWrapper.push(pooledViews, view);
    }
  }
}
