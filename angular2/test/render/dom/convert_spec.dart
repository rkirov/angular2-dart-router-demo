library angular2.test.render.dom.convert_spec;

import "package:angular2/src/facade/collection.dart" show MapWrapper;
import "package:angular2/src/render/api.dart" show DirectiveMetadata;
import "package:angular2/src/render/dom/convert.dart"
    show directiveMetadataFromMap, directiveMetadataToMap;
import "package:angular2/test_lib.dart" show ddescribe, describe, expect, it;

main() {
  describe("convert", () {
    it("directiveMetadataToMap", () {
      var someComponent = new DirectiveMetadata(
          compileChildren: false,
          hostListeners: MapWrapper
              .createFromPairs([["listenKey", "listenVal"]]),
          hostProperties: MapWrapper
              .createFromPairs([["hostPropKey", "hostPropVal"]]),
          hostActions: MapWrapper
              .createFromPairs([["hostActionKey", "hostActionVal"]]),
          id: "someComponent",
          properties: MapWrapper.createFromPairs([["propKey", "propVal"]]),
          readAttributes: ["read1", "read2"],
          selector: "some-comp",
          type: DirectiveMetadata.COMPONENT_TYPE);
      var map = directiveMetadataToMap(someComponent);
      expect(MapWrapper.get(map, "compileChildren")).toEqual(false);
      expect(MapWrapper.get(map, "hostListeners"))
          .toEqual(MapWrapper.createFromPairs([["listenKey", "listenVal"]]));
      expect(MapWrapper.get(map, "hostProperties")).toEqual(
          MapWrapper.createFromPairs([["hostPropKey", "hostPropVal"]]));
      expect(MapWrapper.get(map, "hostActions")).toEqual(
          MapWrapper.createFromPairs([["hostActionKey", "hostActionVal"]]));
      expect(MapWrapper.get(map, "id")).toEqual("someComponent");
      expect(MapWrapper.get(map, "properties"))
          .toEqual(MapWrapper.createFromPairs([["propKey", "propVal"]]));
      expect(MapWrapper.get(map, "readAttributes")).toEqual(["read1", "read2"]);
      expect(MapWrapper.get(map, "selector")).toEqual("some-comp");
      expect(MapWrapper.get(map, "type"))
          .toEqual(DirectiveMetadata.COMPONENT_TYPE);
    });
    it("mapToDirectiveMetadata", () {
      var map = MapWrapper.createFromPairs([
        ["compileChildren", false],
        ["hostListeners", MapWrapper.createFromPairs([["testKey", "testVal"]])],
        [
          "hostProperties",
          MapWrapper.createFromPairs([["hostPropKey", "hostPropVal"]])
        ],
        [
          "hostActions",
          MapWrapper.createFromPairs([["hostActionKey", "hostActionVal"]])
        ],
        ["id", "testId"],
        ["properties", MapWrapper.createFromPairs([["propKey", "propVal"]])],
        ["readAttributes", ["readTest1", "readTest2"]],
        ["selector", "testSelector"],
        ["type", DirectiveMetadata.DIRECTIVE_TYPE]
      ]);
      var meta = directiveMetadataFromMap(map);
      expect(meta.compileChildren).toEqual(false);
      expect(meta.hostListeners)
          .toEqual(MapWrapper.createFromPairs([["testKey", "testVal"]]));
      expect(meta.hostProperties).toEqual(
          MapWrapper.createFromPairs([["hostPropKey", "hostPropVal"]]));
      expect(meta.hostActions).toEqual(
          MapWrapper.createFromPairs([["hostActionKey", "hostActionVal"]]));
      expect(meta.id).toEqual("testId");
      expect(meta.properties)
          .toEqual(MapWrapper.createFromPairs([["propKey", "propVal"]]));
      expect(meta.readAttributes).toEqual(["readTest1", "readTest2"]);
      expect(meta.selector).toEqual("testSelector");
      expect(meta.type).toEqual(DirectiveMetadata.DIRECTIVE_TYPE);
    });
  });
}
