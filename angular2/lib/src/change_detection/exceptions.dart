library angular2.src.change_detection.exceptions;

import "proto_record.dart" show ProtoRecord;
import "package:angular2/src/facade/lang.dart" show BaseException;
// HACK: workaround for Traceur behavior.

// It expects all transpiled modules to contain this marker.

// TODO: remove this when we no longer use traceur
var ___esModule = true;
class ExpressionChangedAfterItHasBeenChecked extends BaseException {
  String message;
  ExpressionChangedAfterItHasBeenChecked(ProtoRecord proto, dynamic change)
      : super() {
    /* super call moved to initializer */;
    this.message =
        '''Expression \'${ proto . expressionAsString}\' has changed after it was checked. ''' +
            '''Previous value: \'${ change . previousValue}\'. Current value: \'${ change . currentValue}\'''';
  }
  String toString() {
    return this.message;
  }
}
class ChangeDetectionError extends BaseException {
  String message;
  dynamic originalException;
  String location;
  ChangeDetectionError(ProtoRecord proto, dynamic originalException) : super() {
    /* super call moved to initializer */;
    this.originalException = originalException;
    this.location = proto.expressionAsString;
    this.message = '''${ this . originalException} in [${ this . location}]''';
  }
  String toString() {
    return this.message;
  }
}
