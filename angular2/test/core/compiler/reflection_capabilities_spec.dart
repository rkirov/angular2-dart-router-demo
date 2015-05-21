library angular2.test.core.compiler.reflection_capabilities_spec;

import "package:angular2/test_lib.dart"
    show ddescribe, describe, it, iit, expect, beforeEach, IS_DARTIUM;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/src/facade/lang.dart" show isPresent, global;

main() {
  var rc;
  beforeEach(() {
    rc = new ReflectionCapabilities();
  });
  assertTestClassAnnotations(annotations) {
    expect(annotations[0]).toBeAnInstanceOf(ClassDec1);
    expect(annotations[1]).toBeAnInstanceOf(ClassDec2);
  }
  assertTestClassParameters(parameters) {
    expect(parameters.length).toBe(4);
    expect(parameters[0].length).toBe(2);
    expect(parameters[0][0]).toEqual(P1);
    expect(parameters[0][1]).toBeAnInstanceOf(ParamDec);
    expect(parameters[1].length).toBe(1);
    expect(parameters[1][0]).toEqual(P2);
    expect(parameters[2].length).toBe(1);
    expect(parameters[2][0]).toBeAnInstanceOf(ParamDec);
    expect(parameters[3].length).toBe(0);
  }
  describe("reflection capabilities", () {
    describe("factory", () {
      it("should create a factory for a type", () {
        var f = rc.factory(ClassWithField);
        expect(f("value").field).toEqual("value");
      });
      it("should throw when a constructor has more than 10 args", () {
        expect(() => rc.factory(ClassWith11Fields))
            .toThrowError(new RegExp('''has more than 10 arguments'''));
      });
    });
    it("can read out class annotations through annotations key", () {
      assertTestClassAnnotations(rc.annotations(TestClass));
    });
    it("can read out parameter annotations through parameters key", () {
      assertTestClassParameters(rc.parameters(TestClass));
    });
    it("can read out parameter annotations through parameters key for types only class",
        () {
      expect(rc.parameters(TestClassTypesOnly)).toEqual([[P1], [P2]]);
    });
    if (!IS_DARTIUM) {
      // Mocking in the tests below is needed because the test runs through Traceur.

      // After the switch to TS the setup will have to change, where the direct key

      // access will be mocked, and the tests below will be direct.
      it("can read out class annotations though Reflect APIs", () {
        var rc = new ReflectionCapabilities({
          "getMetadata": (key, targetCls) {
            return (targetCls == TestClassDec)
                ? mockDataForTestClassDec[key]
                : null;
          }
        });
        assertTestClassAnnotations(rc.annotations(TestClassDec));
      });
      it("can read out parameter annotations though Reflect APIs", () {
        var rc = new ReflectionCapabilities({
          "getMetadata": (key, targetCls) {
            return (targetCls == TestClassDec)
                ? mockDataForTestClassDec[key]
                : null;
          }
        });
        assertTestClassParameters(rc.parameters(TestClassDec));
      });
      it("can read out parameter annotations though Reflect APIs for types only class",
          () {
        var rc = new ReflectionCapabilities({
          "getMetadata": (key, targetCls) {
            return (targetCls == TestClassTypesOnlyDec)
                ? mockDataForTestClassTypesOnly[key]
                : null;
          }
        });
        expect(rc.parameters(TestClassTypesOnlyDec)).toEqual([[P1], [P2]]);
      });
    }
  });
}
class ClassDec1 {
  const ClassDec1();
}
class ClassDec2 {
  const ClassDec2();
}
class ParamDec {
  const ParamDec();
}
class P1 {}
class P2 {}
@ClassDec1()
@ClassDec2()
class TestClass {
  TestClass(@ParamDec() P1 a, P2 b, @ParamDec() c, d) {}
}
// Mocking the data stored in global.Reflect as if TS was compiling TestClass above.
var mockDataForTestClassDec = {
  "annotations": [new ClassDec1(), new ClassDec2()],
  "parameters": [new ParamDec(), null, new ParamDec()],
  "design:paramtypes": [P1, P2, Object, Object]
};
class TestClassDec {}
class TestClassTypesOnly {
  TestClassTypesOnly(P1 a, P2 b) {}
}
class ClassWithField {
  var field;
  ClassWithField(field) {
    this.field = field;
  }
}
class ClassWith11Fields {
  ClassWith11Fields(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10) {}
}
// Mocking the data stored in global.Reflect as if TS was compiling TestClass above.
var mockDataForTestClassTypesOnly = {
  "annotations": null,
  "parameters": null,
  "design:paramtypes": [P1, P2]
};
class TestClassTypesOnlyDec {}
