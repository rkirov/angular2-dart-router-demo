library angular2.src.change_detection.change_detection_util;

import "package:angular2/src/facade/lang.dart"
    show isPresent, isBlank, BaseException, Type;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, MapWrapper, StringMapWrapper;
import "proto_record.dart" show ProtoRecord;
import "exceptions.dart" show ExpressionChangedAfterItHasBeenChecked;
import "pipes/pipe.dart" show WrappedValue;
import "constants.dart"
    show CHECK_ALWAYS, CHECK_ONCE, CHECKED, DETACHED, ON_PUSH;

var uninitialized = new Object();
class SimpleChange {
  dynamic previousValue;
  dynamic currentValue;
  SimpleChange(dynamic previousValue, dynamic currentValue) {
    this.previousValue = previousValue;
    this.currentValue = currentValue;
  }
}
var _simpleChangesIndex = 0;
var _simpleChanges = [
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null),
  new SimpleChange(null, null)
];
_simpleChange(previousValue, currentValue) {
  var index = _simpleChangesIndex++ % 20;
  var s = _simpleChanges[index];
  s.previousValue = previousValue;
  s.currentValue = currentValue;
  return s;
}
class ChangeDetectionUtil {
  static unitialized() {
    return uninitialized;
  }
  static arrayFn0() {
    return [];
  }
  static arrayFn1(a1) {
    return [a1];
  }
  static arrayFn2(a1, a2) {
    return [a1, a2];
  }
  static arrayFn3(a1, a2, a3) {
    return [a1, a2, a3];
  }
  static arrayFn4(a1, a2, a3, a4) {
    return [a1, a2, a3, a4];
  }
  static arrayFn5(a1, a2, a3, a4, a5) {
    return [a1, a2, a3, a4, a5];
  }
  static arrayFn6(a1, a2, a3, a4, a5, a6) {
    return [a1, a2, a3, a4, a5, a6];
  }
  static arrayFn7(a1, a2, a3, a4, a5, a6, a7) {
    return [a1, a2, a3, a4, a5, a6, a7];
  }
  static arrayFn8(a1, a2, a3, a4, a5, a6, a7, a8) {
    return [a1, a2, a3, a4, a5, a6, a7, a8];
  }
  static arrayFn9(a1, a2, a3, a4, a5, a6, a7, a8, a9) {
    return [a1, a2, a3, a4, a5, a6, a7, a8, a9];
  }
  static operation_negate(value) {
    return !value;
  }
  static operation_add(left, right) {
    return left + right;
  }
  static operation_subtract(left, right) {
    return left - right;
  }
  static operation_multiply(left, right) {
    return left * right;
  }
  static operation_divide(left, right) {
    return left / right;
  }
  static operation_remainder(left, right) {
    return left % right;
  }
  static operation_equals(left, right) {
    return left == right;
  }
  static operation_not_equals(left, right) {
    return left != right;
  }
  static operation_less_then(left, right) {
    return left < right;
  }
  static operation_greater_then(left, right) {
    return left > right;
  }
  static operation_less_or_equals_then(left, right) {
    return left <= right;
  }
  static operation_greater_or_equals_then(left, right) {
    return left >= right;
  }
  static operation_logical_and(left, right) {
    return left && right;
  }
  static operation_logical_or(left, right) {
    return left || right;
  }
  static cond(cond, trueVal, falseVal) {
    return cond ? trueVal : falseVal;
  }
  static mapFn(List keys) {
    buildMap(values) {
      var res = StringMapWrapper.create();
      for (var i = 0; i < keys.length; ++i) {
        StringMapWrapper.set(res, keys[i], values[i]);
      }
      return res;
    }
    switch (keys.length) {
      case 0:
        return () => [];
      case 1:
        return (a1) => buildMap([a1]);
      case 2:
        return (a1, a2) => buildMap([a1, a2]);
      case 3:
        return (a1, a2, a3) => buildMap([a1, a2, a3]);
      case 4:
        return (a1, a2, a3, a4) => buildMap([a1, a2, a3, a4]);
      case 5:
        return (a1, a2, a3, a4, a5) => buildMap([a1, a2, a3, a4, a5]);
      case 6:
        return (a1, a2, a3, a4, a5, a6) => buildMap([a1, a2, a3, a4, a5, a6]);
      case 7:
        return (a1, a2, a3, a4, a5, a6, a7) =>
            buildMap([a1, a2, a3, a4, a5, a6, a7]);
      case 8:
        return (a1, a2, a3, a4, a5, a6, a7, a8) =>
            buildMap([a1, a2, a3, a4, a5, a6, a7, a8]);
      case 9:
        return (a1, a2, a3, a4, a5, a6, a7, a8, a9) =>
            buildMap([a1, a2, a3, a4, a5, a6, a7, a8, a9]);
      default:
        throw new BaseException(
            '''Does not support literal maps with more than 9 elements''');
    }
  }
  static keyedAccess(obj, args) {
    return obj[args[0]];
  }
  static dynamic unwrapValue(dynamic value) {
    if (value is WrappedValue) {
      return value.wrapped;
    } else {
      return value;
    }
  }
  static throwOnChange(ProtoRecord proto, change) {
    throw new ExpressionChangedAfterItHasBeenChecked(proto, change);
  }
  static changeDetectionMode(String strategy) {
    return strategy == ON_PUSH ? CHECK_ONCE : CHECK_ALWAYS;
  }
  static SimpleChange simpleChange(
      dynamic previousValue, dynamic currentValue) {
    return _simpleChange(previousValue, currentValue);
  }
  static addChange(changes, String propertyName, change) {
    if (isBlank(changes)) {
      changes = {};
    }
    changes[propertyName] = change;
    return changes;
  }
}
