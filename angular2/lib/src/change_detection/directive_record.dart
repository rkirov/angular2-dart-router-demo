library angular2.src.change_detection.directive_record;

import "constants.dart" show ON_PUSH;
import "package:angular2/src/facade/lang.dart" show StringWrapper;

class DirectiveIndex {
  num elementIndex;
  num directiveIndex;
  DirectiveIndex(this.elementIndex, this.directiveIndex) {}
  get name {
    return '''${ this . elementIndex}_${ this . directiveIndex}''';
  }
}
class DirectiveRecord {
  DirectiveIndex directiveIndex;
  bool callOnAllChangesDone;
  bool callOnChange;
  String changeDetection;
  DirectiveRecord(this.directiveIndex, this.callOnAllChangesDone,
      this.callOnChange, this.changeDetection) {}
  bool isOnPushChangeDetection() {
    return StringWrapper.equals(this.changeDetection, ON_PUSH);
  }
}
