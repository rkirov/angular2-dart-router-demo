library examples.src.sourcemap.index;

import "package:angular2/src/facade/lang.dart" show BaseException, print, CONST;
import "package:angular2/angular2.dart"
    show
        bootstrap; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

@Component(selector: "error-app")
@View(template: '''
           <button class="errorButton" (click)="createError()">create error</button>''',
    directives: const [])
class ErrorComponent {
  createError() {
    throw new BaseException("Sourcemap test");
  }
}
main() {
  bootstrap(ErrorComponent);
}
