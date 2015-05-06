library angular2.src.forms.form_builder;

import "package:angular2/src/facade/collection.dart"
    show StringMapWrapper, ListWrapper, List;
import "package:angular2/src/facade/lang.dart" show isPresent;
import "model.dart"
    as modelModule; /**
 * Creates a form object from a user-specified configuration.
 *
 * # Example
 *
 * This example creates a {@link ControlGroup} that consists of a `login` {@link Control}, and a nested 
 * {@link ControlGroup} that defines a `password` and a `passwordConfirmation` {@link Control}.
 *
 * ```
 *  var loginForm = builder.group({
 *    login: ["", Validators.required],
 *
 *    passwordRetry: builder.group({
 *      password: ["", Validators.required],
 *      passwordConfirmation: ["", Validators.required]
 *    })
 *  });
 *
 *  ```
 * @exportedAs angular2/forms
 */

class FormBuilder {
  modelModule.ControlGroup group(controlsConfig, [extra = null]) {
    var controls = this._reduceControls(controlsConfig);
    var optionals =
        isPresent(extra) ? StringMapWrapper.get(extra, "optionals") : null;
    var validator =
        isPresent(extra) ? StringMapWrapper.get(extra, "validator") : null;
    if (isPresent(validator)) {
      return new modelModule.ControlGroup(controls, optionals, validator);
    } else {
      return new modelModule.ControlGroup(controls, optionals);
    }
  }
  modelModule.Control control(value, [Function validator = null]) {
    if (isPresent(validator)) {
      return new modelModule.Control(value, validator);
    } else {
      return new modelModule.Control(value);
    }
  }
  modelModule.ControlArray array(List controlsConfig,
      [Function validator = null]) {
    var controls =
        ListWrapper.map(controlsConfig, (c) => this._createControl(c));
    if (isPresent(validator)) {
      return new modelModule.ControlArray(controls, validator);
    } else {
      return new modelModule.ControlArray(controls);
    }
  }
  _reduceControls(controlsConfig) {
    var controls = {};
    StringMapWrapper.forEach(controlsConfig, (controlConfig, controlName) {
      controls[controlName] = this._createControl(controlConfig);
    });
    return controls;
  }
  _createControl(controlConfig) {
    if (controlConfig is modelModule.Control ||
        controlConfig is modelModule.ControlGroup ||
        controlConfig is modelModule.ControlArray) {
      return controlConfig;
    } else if (ListWrapper.isList(controlConfig)) {
      var value = ListWrapper.get(controlConfig, 0);
      var validator = controlConfig.length > 1 ? controlConfig[1] : null;
      return this.control(value, validator);
    } else {
      return this.control(controlConfig);
    }
  }
}
