library angular2.src.forms.model;

import "package:angular2/src/facade/lang.dart" show isPresent;
import "package:angular2/src/facade/async.dart"
    show Stream, EventEmitter, ObservableWrapper;
import "package:angular2/src/facade/collection.dart"
    show Map, StringMapWrapper, ListWrapper, List;
import "validators.dart" show Validators;

/**
 * Indicates that a Control is valid, i.e. that no errors exist in the input value.
 *
 * @exportedAs angular2/forms
 */
const VALID = "VALID";
/**
 * Indicates that a Control is invalid, i.e. that an error exists in the input value.
 *
 * @exportedAs angular2/forms
 */
const INVALID = "INVALID";
//interface IControl {

//  get value():any;

//  validator:Function;

//  get status():string;

//  get valid():boolean;

//  get errors():Map;

//  get pristine():boolean;

//  get dirty():boolean;

//  updateValue(value:any){}

//  setParent(parent){}

//}
bool isControl(Object c) {
  return c is AbstractControl;
}
/**
 * Omitting from external API doc as this is really an abstract internal concept.
 */
class AbstractControl {
  dynamic _value;
  String _status;
  Map _errors;
  bool _pristine;
  dynamic _parent;
  Function validator;
  EventEmitter _valueChanges;
  AbstractControl(Function validator) {
    this.validator = validator;
    this._pristine = true;
  }
  dynamic get value {
    return this._value;
  }
  String get status {
    return this._status;
  }
  bool get valid {
    return identical(this._status, VALID);
  }
  Map get errors {
    return this._errors;
  }
  bool get pristine {
    return this._pristine;
  }
  bool get dirty {
    return !this.pristine;
  }
  Stream get valueChanges {
    return this._valueChanges;
  }
  setParent(parent) {
    this._parent = parent;
  }
  _updateParent() {
    if (isPresent(this._parent)) {
      this._parent._updateValue();
    }
  }
}
/**
 * Defines a part of a form that cannot be divided into other controls.
 *
 * `Control` is one of the three fundamental building blocks used to define forms in Angular, along with 
 * {@link ControlGroup} and {@link ControlArray}.
 *
 * @exportedAs angular2/forms
 */
class Control extends AbstractControl {
  Control(dynamic value, [Function validator = Validators.nullValidator])
      : super(validator) {
    /* super call moved to initializer */;
    this._setValueErrorsStatus(value);
    this._valueChanges = new EventEmitter();
  }
  void updateValue(dynamic value) {
    this._setValueErrorsStatus(value);
    this._pristine = false;
    ObservableWrapper.callNext(this._valueChanges, this._value);
    this._updateParent();
  }
  _setValueErrorsStatus(value) {
    this._value = value;
    this._errors = this.validator(this);
    this._status = isPresent(this._errors) ? INVALID : VALID;
  }
}
/**
 * Defines a part of a form, of fixed length, that can contain other controls.
 *
 * A ControlGroup aggregates the values and errors of each {@link Control} in the group. Thus, if one of the controls 
 * in a group is invalid, the entire group is invalid. Similarly, if a control changes its value, the entire group 
 * changes as well.
 *
 * `ControlGroup` is one of the three fundamental building blocks used to define forms in Angular, along with 
 * {@link Control} and {@link ControlArray}. {@link ControlArray} can also contain other controls, but is of variable 
 * length.
 *
 * @exportedAs angular2/forms
 */
class ControlGroup extends AbstractControl {
  Map controls;
  Map _optionals;
  ControlGroup(Map controls,
      [Map optionals = null, Function validator = Validators.group])
      : super(validator) {
    /* super call moved to initializer */;
    this.controls = controls;
    this._optionals = isPresent(optionals) ? optionals : {};
    this._valueChanges = new EventEmitter();
    this._setParentForControls();
    this._setValueErrorsStatus();
  }
  void include(String controlName) {
    StringMapWrapper.set(this._optionals, controlName, true);
    this._updateValue();
  }
  void exclude(String controlName) {
    StringMapWrapper.set(this._optionals, controlName, false);
    this._updateValue();
  }
  bool contains(String controlName) {
    var c = StringMapWrapper.contains(this.controls, controlName);
    return c && this._included(controlName);
  }
  _setParentForControls() {
    StringMapWrapper.forEach(this.controls, (control, name) {
      control.setParent(this);
    });
  }
  _updateValue() {
    this._setValueErrorsStatus();
    this._pristine = false;
    ObservableWrapper.callNext(this._valueChanges, this._value);
    this._updateParent();
  }
  _setValueErrorsStatus() {
    this._value = this._reduceValue();
    this._errors = this.validator(this);
    this._status = isPresent(this._errors) ? INVALID : VALID;
  }
  _reduceValue() {
    return this._reduceChildren({}, (acc, control, name) {
      acc[name] = control.value;
      return acc;
    });
  }
  _reduceChildren(dynamic initValue, Function fn) {
    var res = initValue;
    StringMapWrapper.forEach(this.controls, (control, name) {
      if (this._included(name)) {
        res = fn(res, control, name);
      }
    });
    return res;
  }
  bool _included(String controlName) {
    var isOptional = StringMapWrapper.contains(this._optionals, controlName);
    return !isOptional || StringMapWrapper.get(this._optionals, controlName);
  }
}
/**
 * Defines a part of a form, of variable length, that can contain other controls.
 *
 * A `ControlArray` aggregates the values and errors of each {@link Control} in the group. Thus, if one of the controls 
 * in a group is invalid, the entire group is invalid. Similarly, if a control changes its value, the entire group 
 * changes as well.
 *
 * `ControlArray` is one of the three fundamental building blocks used to define forms in Angular, along with 
 * {@link Control} and {@link ControlGroup}. {@link ControlGroup} can also contain other controls, but is of fixed 
 * length.
 *
 * @exportedAs angular2/forms
 */
class ControlArray extends AbstractControl {
  List controls;
  ControlArray(List<AbstractControl> controls,
      [Function validator = Validators.array])
      : super(validator) {
    /* super call moved to initializer */;
    this.controls = controls;
    this._valueChanges = new EventEmitter();
    this._setParentForControls();
    this._setValueErrorsStatus();
  }
  AbstractControl at(num index) {
    return this.controls[index];
  }
  void push(AbstractControl control) {
    ListWrapper.push(this.controls, control);
    control.setParent(this);
    this._updateValue();
  }
  void insert(num index, AbstractControl control) {
    ListWrapper.insert(this.controls, index, control);
    control.setParent(this);
    this._updateValue();
  }
  void removeAt(num index) {
    ListWrapper.removeAt(this.controls, index);
    this._updateValue();
  }
  num get length {
    return this.controls.length;
  }
  _updateValue() {
    this._setValueErrorsStatus();
    this._pristine = false;
    ObservableWrapper.callNext(this._valueChanges, this._value);
    this._updateParent();
  }
  _setParentForControls() {
    ListWrapper.forEach(this.controls, (control) {
      control.setParent(this);
    });
  }
  _setValueErrorsStatus() {
    this._value = ListWrapper.map(this.controls, (c) => c.value);
    this._errors = this.validator(this);
    this._status = isPresent(this._errors) ? INVALID : VALID;
  }
}
