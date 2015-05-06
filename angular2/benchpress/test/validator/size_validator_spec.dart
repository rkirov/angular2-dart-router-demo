library benchpress.test.validator.size_validator_spec;

import "package:angular2/test_lib.dart"
    show describe, ddescribe, it, iit, xit, expect, beforeEach, afterEach;
import "package:angular2/src/facade/lang.dart" show DateTime, DateWrapper;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:benchpress/common.dart"
    show Validator, SizeValidator, Injector, bind, MeasureValues;

main() {
  describe("size validator", () {
    var validator;
    createValidator(size) {
      validator = Injector
          .resolveAndCreate([
        SizeValidator.BINDINGS,
        bind(SizeValidator.SAMPLE_SIZE).toValue(size)
      ])
          .get(SizeValidator);
    }
    it("should return sampleSize as description", () {
      createValidator(2);
      expect(validator.describe()).toEqual({"sampleSize": 2});
    });
    it("should return null while the completeSample is smaller than the given size",
        () {
      createValidator(2);
      expect(validator.validate([])).toBe(null);
      expect(validator.validate([mv(0, 0, {})])).toBe(null);
    });
    it("should return the last sampleSize runs when it has at least the given size",
        () {
      createValidator(2);
      var sample = [mv(0, 0, {"a": 1}), mv(1, 1, {"b": 2}), mv(2, 2, {"c": 3})];
      expect(validator.validate(ListWrapper.slice(sample, 0, 2)))
          .toEqual(ListWrapper.slice(sample, 0, 2));
      expect(validator.validate(sample))
          .toEqual(ListWrapper.slice(sample, 1, 3));
    });
  });
}
mv(runIndex, time, values) {
  return new MeasureValues(runIndex, DateWrapper.fromMillis(time), values);
}
