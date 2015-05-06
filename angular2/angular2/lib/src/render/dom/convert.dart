library angular2.src.render.dom.convert;

import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/render/api.dart"
    show
        DirectiveMetadata; /**
 * Converts a [DirectiveMetadata] to a map representation. This creates a copy,
 * that is, subsequent changes to `meta` will not be mirrored in the map.
 */

Map directiveMetadataToMap(DirectiveMetadata meta) {
  return MapWrapper.createFromPairs([
    ["id", meta.id],
    ["selector", meta.selector],
    ["compileChildren", meta.compileChildren],
    ["hostListeners", _cloneIfPresent(meta.hostListeners)],
    ["hostProperties", _cloneIfPresent(meta.hostProperties)],
    ["properties", _cloneIfPresent(meta.properties)],
    ["readAttributes", _cloneIfPresent(meta.readAttributes)],
    ["type", meta.type],
    ["version", 1]
  ]);
} /**
 * Converts a map representation of [DirectiveMetadata] into a
 * [DirectiveMetadata] object. This creates a copy, that is, subsequent changes
 * to `map` will not be mirrored in the [DirectiveMetadata] object.
 */
DirectiveMetadata directiveMetadataFromMap(Map map) {
  return new DirectiveMetadata(
      id: MapWrapper.get(map, "id"),
      selector: MapWrapper.get(map, "selector"),
      compileChildren: MapWrapper.get(map, "compileChildren"),
      hostListeners: _cloneIfPresent(MapWrapper.get(map, "hostListeners")),
      hostProperties: _cloneIfPresent(MapWrapper.get(map, "hostProperties")),
      properties: _cloneIfPresent(MapWrapper.get(map, "properties")),
      readAttributes: _cloneIfPresent(MapWrapper.get(map, "readAttributes")),
      type: MapWrapper.get(map, "type"));
} /**
 * Clones the [List] or [Map] `o` if it is present.
 */
_cloneIfPresent(o) {
  if (!isPresent(o)) return null;
  return ListWrapper.isList(o) ? ListWrapper.clone(o) : MapWrapper.clone(o);
}
