library angular2.test.core.compiler.reflection_capabilities_spec;

import "package:angular2/test_lib.dart"
    show ddescribe, describe, it, iit, expect, beforeEach, IS_DARTIUM;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;
import "package:angular2/src/facade/lang.dart" show isPresent, global, CONST;

main() {
  var rc;
  beforeEach(() {
    rc = new ReflectionCapabilities();
  });
  mockReflect(mockData, cls) {
    // This only makes sense for JS, but Dart passes trivially too.
    if (!IS_DARTIUM) {
      global.Reflect = {
        "getMetadata": (key, targetCls) {
          return (targetCls == cls) ? mockData[key] : null;
        }
      };
    }
  }
  assertTestClassAnnotations(annotations) {
    expect(annotations[0]).toBeAnInstanceOf(ClassDec1);
    expect(annotations[1]).toBeAnInstanceOf(ClassDec2);
  }
  assertTestClassParameters(parameters) {
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
    it("can read out class annotations through annotations key", () {
      assertTestClassAnnotations(rc.annotations(TestClass));
    });
    it("can read out parameter annotations through parameters key", () {
      assertTestClassParameters(rc.parameters(TestClass));
    }); // Mocking in the tests below is needed because the test runs through Traceur.
    // After the switch to TS the setup will have to change, where the direct key
    // access will be mocked, and the tests below will be direct.
    it("can read out class annotations though Reflect APIs", () {
      if (IS_DARTIUM) return;
      mockReflect(mockDataForTestClassDec, TestClassDec);
      assertTestClassAnnotations(rc.annotations(TestClassDec));
    });
    it("can read out parameter annotations though Reflect APIs", () {
      if (IS_DARTIUM) return;
      mockReflect(mockDataForTestClassDec, TestClassDec);
      assertTestClassParameters(rc.parameters(TestClassDec));
    });
  });
}
class ClassDec1 {
  @CONST() const ClassDec1();
}
class ClassDec2 {
  @CONST() const ClassDec2();
}
class ParamDec {
  @CONST() const ParamDec();
}
class P1 {}
class P2 {}
@ClassDec1()
@ClassDec2()
class TestClass {
  TestClass(@ParamDec() P1 a, P2 b, @ParamDec() c, d) {}
} // Mocking the data stored in global.Reflect as if TS was compiling TestClass above.
var mockDataForTestClassDec = {
  "annotations": [new ClassDec1(), new ClassDec2()],
  "parameters": [new ParamDec(), null, new ParamDec()],
  "design:paramtypes": [P1, P2, Object, Object]
};
class TestClassDec {}
