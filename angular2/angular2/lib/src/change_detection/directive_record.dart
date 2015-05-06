library angular2.src.change_detection.directive_record;

import "constants.dart" show ON_PUSH;
import "package:angular2/src/facade/lang.dart" show StringWrapper;

class DirectiveIndex {
  num elementIndex;
  num directiveIndex;
  DirectiveIndex(num elementIndex, num directiveIndex) {
    this.elementIndex = elementIndex;
    this.directiveIndex = directiveIndex;
  }
  get name {
    return '''${ this . elementIndex}_${ this . directiveIndex}''';
  }
}
class DirectiveRecord {
  DirectiveIndex directiveIndex;
  bool callOnAllChangesDone;
  bool callOnChange;
  String changeDetection;
  DirectiveRecord(DirectiveIndex directiveIndex, bool callOnAllChangesDone,
      bool callOnChange, String changeDetection) {
    this.directiveIndex = directiveIndex;
    this.callOnAllChangesDone = callOnAllChangesDone;
    this.callOnChange = callOnChange;
    this.changeDetection = changeDetection;
  }
  bool isOnPushChangeDetection() {
    return StringWrapper.equals(this.changeDetection, ON_PUSH);
  }
}
