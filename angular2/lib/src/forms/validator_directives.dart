library angular2.src.forms.validator_directives;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Directive;
import "validators.dart" show Validators;
import "directives.dart" show ControlDirective;

@Directive(selector: "[required]")
class RequiredValidatorDirective {
  RequiredValidatorDirective(ControlDirective c) {
    c.validator = Validators.compose([c.validator, Validators.required]);
  }
}
