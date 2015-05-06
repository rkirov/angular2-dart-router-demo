library angular2_material.src.core.theme;

import "package:angular2/angular2.dart" show Directive;

@Directive(selector: "[md-theme]")
class MdTheme {
  String color;
  MdTheme() {
    this.color = "sky-blue";
  }
}
