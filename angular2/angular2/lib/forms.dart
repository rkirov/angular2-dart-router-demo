/**
 * @module
 * @public
 * @description
 * This module is used for handling user input, by defining and building a {@link ControlGroup} that consists of
 * {@link Control} objects, and mapping them onto the DOM. {@link Control} objects can then be used to read information
 * from the form DOM elements.
 *
 * This module is not included in the `angular2` module; you must import the forms module explicitly.
 *
 */
library angular2.forms;

export "src/forms/model.dart";
export "src/forms/directives.dart";
export "src/forms/validators.dart";
export "src/forms/validator_directives.dart";
export "src/forms/form_builder.dart";
