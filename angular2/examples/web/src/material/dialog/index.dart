library examples.src.material.dialog.index;

import "package:angular2/angular2.dart"
    show bootstrap, ElementRef, ComponentRef;
import "package:angular2_material/src/components/dialog/dialog.dart"
    show MdDialog, MdDialogRef, MdDialogConfig;
import "package:angular2/src/services/url_resolver.dart" show UrlResolver;
import "../demo_common.dart" show commonDemoSetup, DemoUrlResolver;
import "package:angular2/di.dart" show bind, Injector;
import "package:angular2/src/facade/lang.dart"
    show
        isPresent; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

@Component(selector: "demo-app", injectables: const [MdDialog])
@View(templateUrl: "./demo_app.html", directives: const [])
class DemoApp {
  MdDialog dialog;
  ElementRef elementRef;
  MdDialogRef dialogRef;
  MdDialogConfig dialogConfig;
  Injector injector;
  String lastResult;
  DemoApp(MdDialog mdDialog, ElementRef elementRef, Injector injector) {
    this.dialog = mdDialog;
    this.elementRef = elementRef;
    this.dialogConfig = new MdDialogConfig();
    this.injector = injector;
    this.dialogConfig.width = "60%";
    this.dialogConfig.height = "60%";
    this.lastResult = "";
  }
  open() {
    if (isPresent(this.dialogRef)) {
      return;
    }
    this.dialog
        .open(SimpleDialogComponent, this.elementRef, this.injector,
            this.dialogConfig)
        .then((ref) {
      this.dialogRef = ref;
      ref.instance.numCoconuts = 777;
      ref.whenClosed.then((result) {
        this.dialogRef = null;
        this.lastResult = result;
      });
    });
  }
  close() {
    this.dialogRef.close();
  }
}
@Component(
    selector: "simple-dialog", properties: const {"numCoconuts": "numCoconuts"})
@View(template: '''
    <h2>This is the dialog content</h2>
    <p>There are {{numCoconuts}} coconuts.</p>
    <p>Return: <input (input)="updateValue(\$event)"></p>
    <button type="button" (click)="done()">Done</button>
  ''')
class SimpleDialogComponent {
  num numCoconuts;
  MdDialogRef dialogRef;
  String toReturn;
  SimpleDialogComponent(MdDialogRef dialogRef) {
    this.numCoconuts = 0;
    this.dialogRef = dialogRef;
    this.toReturn = "";
  }
  updateValue(event) {
    this.toReturn = event.target.value;
  }
  done() {
    this.dialogRef.close(this.toReturn);
  }
}
main() {
  commonDemoSetup();
  bootstrap(DemoApp, [bind(UrlResolver).toValue(new DemoUrlResolver())]);
}
