/**
 * @module
 * @public
 * @description
 * Common directives shipped with Angular.
 */
library angular2.directives;

import "src/directives/ng_for.dart" show NgFor;
import "src/directives/ng_if.dart" show NgIf;
import "src/directives/ng_non_bindable.dart" show NgNonBindable;
import "src/directives/ng_switch.dart"
    show NgSwitch, NgSwitchWhen, NgSwitchDefault;
export "src/directives/class.dart";
export "src/directives/ng_for.dart";
export "src/directives/ng_if.dart";
export "src/directives/ng_non_bindable.dart";
export "src/directives/ng_switch.dart";

/**
 * A collection of the Angular core directives that are likely to be used in each and every Angular application.
 *
 * This collection can be used to quickly enumerate all the built-in directives in the `@View` annotation. For example,
 * instead of writing:
 *
 * ```
 * import {If, NgFor, NgSwitch, NgSwitchWhen, NgSwitchDefault} from 'angular2/angular2';
 * import {OtherDirective} from 'myDirectives';
 *
 * @Component({
 *  selector: 'my-component'
 * })
 * @View({
 *   templateUrl: 'myComponent.html',
 *   directives: [If, NgFor, NgSwitch, NgSwitchWhen, NgSwitchDefault, OtherDirective]
 * })
 * export class MyComponent {
 *   ...
 * }
 * ```
 * one could enumerate all the core directives at once:
 *
 * ```
 * import {coreDirectives} from 'angular2/angular2';
 * import {OtherDirective} from 'myDirectives';
 *
 * @Component({
 *  selector: 'my-component'
 * })
 * @View({
 *   templateUrl: 'myComponent.html',
 *   directives: [coreDirectives, OtherDirective]
 * })
 * export class MyComponent {
 *   ...
 * }
 * ```
 *
 */
const List coreDirectives = const [
  NgFor,
  NgIf,
  NgNonBindable,
  NgSwitch,
  NgSwitchWhen,
  NgSwitchDefault
];
