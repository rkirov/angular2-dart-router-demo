/**
 *
 *
 * @exportedAs angular2/di
 */
library angular2.src.di.opaque_token;

class OpaqueToken {
  String _desc;
  OpaqueToken(String desc) {
    this._desc = '''Token(${ desc})''';
  }
  String toString() {
    return this._desc;
  }
}
