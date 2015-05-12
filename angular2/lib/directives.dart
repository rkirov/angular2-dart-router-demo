/**
 * @module
 * @public
 * @description
 * Common directives shipped with Angular.
 */
library angular2.directives;

import "src/directives/for.dart" show For;
import "src/directives/if.dart" show If;
import "src/directives/non_bindable.dart" show NonBindable;
import "src/directives/switch.dart" show Switch, SwitchWhen, SwitchDefault;
export "src/directives/class.dart";
export "src/directives/for.dart";
export "src/directives/if.dart";
export "src/directives/non_bindable.dart";
export "src/directives/switch.dart";

/**
 * A collection of the Angular core directives that are likely to be used in each and every Angular application.
 *
 * This collection can be used to quickly enumerate all the built-in directives in the `@View` annotation. For example,
 * instead of writing:
 *
 * ```
 * import {If, For, Switch, SwitchWhen, SwitchDefault} from 'angular2/angular2';
 * import {OtherDirective} from 'myDirectives';
 *
 * @Component({
 *  selector: 'my-component'
 * })
 * @View({
 *   templateUrl: 'myComponent.html',
 *   directives: [If, For, Switch, SwitchWhen, SwitchDefault, OtherDirective]
 * })
 * export class MyComponent {
 *   ...
 * }
 * ```
 * one could enumerate all the core directives at once:
 *
 ** ```
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
  For,
  If,
  NonBindable,
  Switch,
  SwitchWhen,
  SwitchDefault
];
