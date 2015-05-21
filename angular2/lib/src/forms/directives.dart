library angular2.src.forms.directives;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "package:angular2/src/core/annotations_impl/visibility.dart"
    show Ancestor;
import "package:angular2/src/core/compiler/element_ref.dart" show ElementRef;
import "package:angular2/src/di/annotations_impl.dart" show Optional;
import "package:angular2/src/render/api.dart" show Renderer;
import "package:angular2/src/facade/lang.dart"
    show isPresent, isString, isBlank, BaseException;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "model.dart" show ControlGroup, Control, isControl;
import "validators.dart" show Validators;
//export interface ControlValueAccessor {

//  writeValue(value):void{}

//  set onChange(fn){}

//}
dynamic _lookupControl(
    ControlGroupDirective groupDirective, dynamic controlOrName) {
  if (isControl(controlOrName)) {
    return controlOrName;
  }
  if (isBlank(groupDirective)) {
    throw new BaseException(
        '''No control group found for "${ controlOrName}"''');
  }
  var control = groupDirective.findControl(controlOrName);
  if (isBlank(control)) {
    throw new BaseException('''Cannot find control "${ controlOrName}"''');
  }
  return control;
}
/**
 * The default accessor for writing a value and listening to changes that is used by a {@link Control} directive.
 *
 * This is the default strategy that Angular uses when no other accessor is applied.
 *
 *  # Example
 *  ```
 *  <input type="text" [control]="loginControl">
 *  ```
 *
 * @exportedAs angular2/forms
 */
@Directive(
    selector: "[control]",
    hostListeners: const {
  "change": "onChange(\$event.target.value)",
  "input": "onChange(\$event.target.value)"
},
    hostProperties: const {"value": "value"})
class DefaultValueAccessor {
  var value;
  Function onChange;
  DefaultValueAccessor() {
    this.onChange = (_) {};
  }
  writeValue(value) {
    this.value = value;
  }
}
/**
 * The accessor for writing a value and listening to changes on a checkbox input element.
 *
 *
 *  # Example
 *  ```
 *  <input type="checkbox" [control]="rememberLogin">
 *  ```
 *
 * @exportedAs angular2/forms
 */
@Directive(
    selector: "input[type=checkbox][control]",
    hostListeners: const {"change": "onChange(\$event.target.checked)"},
    hostProperties: const {"checked": "checked"})
class CheckboxControlValueAccessor {
  ElementRef _elementRef;
  Renderer _renderer;
  bool checked;
  Function onChange;
  CheckboxControlValueAccessor(
      ControlDirective cd, ElementRef elementRef, Renderer renderer) {
    this.onChange = (_) {};
    this._elementRef = elementRef;
    this._renderer = renderer;
    cd.valueAccessor = this;
  }
  writeValue(value) {
    this._renderer.setElementProperty(this._elementRef.parentView.render,
        this._elementRef.boundElementIndex, "checked", value);
  }
}
/**
 * Binds a control to a DOM element.
 *
 * # Example
 *
 * In this example, we bind the control to an input element. When the value of the input element changes, the value of
 * the control will reflect that change. Likewise, if the value of the control changes, the input element reflects that
 * change.
 *
 * Here we use {@link formDirectives}, rather than importing each form directive individually, e.g.
 * `ControlDirective`, `ControlGroupDirective`. This is just a shorthand for the same end result.
 *
 *  ```
 * @Component({selector: "login-comp"})
 * @View({
 *      directives: [formDirectives],
 *      inline: "<input type='text' [control]='loginControl'>"
 *      })
 * class LoginComp {
 *  loginControl:Control;
 *
 *  constructor() {
 *    this.loginControl = new Control('');
 *  }
 * }
 *
 *  ```
 *
 * @exportedAs angular2/forms
 */
@Directive(
    selector: "[control]", properties: const {"controlOrName": "control"})
class ControlDirective {
  ControlGroupDirective _groupDirective;
  dynamic _controlOrName;
  dynamic valueAccessor;
  Function validator;
  ControlDirective(@Optional() @Ancestor() ControlGroupDirective groupDirective,
      DefaultValueAccessor valueAccessor) {
    this._groupDirective = groupDirective;
    this._controlOrName = null;
    this.valueAccessor = valueAccessor;
    this.validator = Validators.nullValidator;
  }
  set controlOrName(controlOrName) {
    this._controlOrName = controlOrName;
    if (isPresent(this._groupDirective)) {
      this._groupDirective.addDirective(this);
    }
    var c = this._control();
    c.validator = Validators.compose([c.validator, this.validator]);
    this._updateDomValue();
    this._setUpUpdateControlValue();
  }
  _updateDomValue() {
    this.valueAccessor.writeValue(this._control().value);
  }
  _setUpUpdateControlValue() {
    this.valueAccessor.onChange =
        (newValue) => this._control().updateValue(newValue);
  }
  _control() {
    return _lookupControl(this._groupDirective, this._controlOrName);
  }
}
/**
 * Binds a control group to a DOM element.
 *
 * # Example
 *
 * In this example, we bind the control group to the form element, and we bind the login and password controls to the
 * login and password elements.
 *
 * Here we use {@link formDirectives}, rather than importing each form directive individually, e.g.
 * `ControlDirective`, `ControlGroupDirective`. This is just a shorthand for the same end result.
 *
 *  ```
 * @Component({selector: "login-comp"})
 * @View({
 *      directives: [formDirectives],
 *      inline: "<form [control-group]='loginForm'>" +
 *              "Login <input type='text' control='login'>" +
 *              "Password <input type='password' control='password'>" +
 *              "<button (click)="onLogin()">Login</button>" +
 *              "</form>"
 *      })
 * class LoginComp {
 *  loginForm:ControlGroup;
 *
 *  constructor() {
 *    this.loginForm = new ControlGroup({
 *      login: new Control(""),
 *      password: new Control("")
 *    });
 *  }
 *
 *  onLogin() {
 *    // this.loginForm.value
 *  }
 * }
 *
 *  ```
 *
 * @exportedAs angular2/forms
 */
@Directive(
    selector: "[control-group]",
    properties: const {"controlOrName": "control-group"})
class ControlGroupDirective {
  ControlGroupDirective _groupDirective;
  List<ControlDirective> _directives;
  dynamic _controlOrName;
  ControlGroupDirective(
      @Optional() @Ancestor() ControlGroupDirective groupDirective) {
    this._groupDirective = groupDirective;
    this._directives = ListWrapper.create();
  }
  set controlOrName(controlOrName) {
    this._controlOrName = controlOrName;
    this._updateDomValue();
  }
  _updateDomValue() {
    ListWrapper.forEach(this._directives, (cd) => cd._updateDomValue());
  }
  addDirective(ControlDirective c) {
    ListWrapper.push(this._directives, c);
  }
  dynamic findControl(String name) {
    return this._getControlGroup().controls[name];
  }
  ControlGroup _getControlGroup() {
    return _lookupControl(this._groupDirective, this._controlOrName);
  }
}
/**
 *
 * A list of all the form directives used as part of a `@View` annotation.
 *
 *  This is a shorthand for importing them each individually.
 *
 * @exportedAs angular2/forms
 */
const List formDirectives = const [
  ControlGroupDirective,
  ControlDirective,
  CheckboxControlValueAccessor,
  DefaultValueAccessor
];
