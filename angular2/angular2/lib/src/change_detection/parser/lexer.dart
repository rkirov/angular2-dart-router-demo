library angular2.src.change_detection.parser.lexer;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, SetWrapper;
import "package:angular2/src/facade/lang.dart"
    show int, NumberWrapper, StringJoiner, StringWrapper;

const TOKEN_TYPE_CHARACTER = 1;
const TOKEN_TYPE_IDENTIFIER = 2;
const TOKEN_TYPE_KEYWORD = 3;
const TOKEN_TYPE_STRING = 4;
const TOKEN_TYPE_OPERATOR = 5;
const TOKEN_TYPE_NUMBER = 6;
@Injectable()
class Lexer {
  String text;
  List tokenize(String text) {
    var scanner = new _Scanner(text);
    var tokens = [];
    var token = scanner.scanToken();
    while (token != null) {
      ListWrapper.push(tokens, token);
      token = scanner.scanToken();
    }
    return tokens;
  }
}
class Token {
  int index;
  int type;
  num _numValue;
  String _strValue;
  Token(int index, int type, num numValue, String strValue) {
    /**
     * NOTE: To ensure that this constructor creates the same hidden class each time, ensure that
     * all the fields are assigned to in the exact same order in each run of this constructor.
     */
    this.index = index;
    this.type = type;
    this._numValue = numValue;
    this._strValue = strValue;
  }
  bool isCharacter(int code) {
    return (this.type == TOKEN_TYPE_CHARACTER && this._numValue == code);
  }
  bool isNumber() {
    return (this.type == TOKEN_TYPE_NUMBER);
  }
  bool isString() {
    return (this.type == TOKEN_TYPE_STRING);
  }
  bool isOperator(String operater) {
    return (this.type == TOKEN_TYPE_OPERATOR && this._strValue == operater);
  }
  bool isIdentifier() {
    return (this.type == TOKEN_TYPE_IDENTIFIER);
  }
  bool isKeyword() {
    return (this.type == TOKEN_TYPE_KEYWORD);
  }
  bool isKeywordVar() {
    return (this.type == TOKEN_TYPE_KEYWORD && this._strValue == "var");
  }
  bool isKeywordNull() {
    return (this.type == TOKEN_TYPE_KEYWORD && this._strValue == "null");
  }
  bool isKeywordUndefined() {
    return (this.type == TOKEN_TYPE_KEYWORD && this._strValue == "undefined");
  }
  bool isKeywordTrue() {
    return (this.type == TOKEN_TYPE_KEYWORD && this._strValue == "true");
  }
  bool isKeywordFalse() {
    return (this.type == TOKEN_TYPE_KEYWORD && this._strValue == "false");
  }
  num toNumber() {
    // -1 instead of NULL ok?
    return (this.type == TOKEN_TYPE_NUMBER) ? this._numValue : -1;
  }
  String toString() {
    int type = this.type;
    if (type >= TOKEN_TYPE_CHARACTER && type <= TOKEN_TYPE_STRING) {
      return this._strValue;
    } else if (type == TOKEN_TYPE_NUMBER) {
      return this._numValue.toString();
    } else {
      return null;
    }
  }
}
Token newCharacterToken(int index, int code) {
  return new Token(
      index, TOKEN_TYPE_CHARACTER, code, StringWrapper.fromCharCode(code));
}
Token newIdentifierToken(int index, String text) {
  return new Token(index, TOKEN_TYPE_IDENTIFIER, 0, text);
}
Token newKeywordToken(int index, String text) {
  return new Token(index, TOKEN_TYPE_KEYWORD, 0, text);
}
Token newOperatorToken(int index, String text) {
  return new Token(index, TOKEN_TYPE_OPERATOR, 0, text);
}
Token newStringToken(int index, String text) {
  return new Token(index, TOKEN_TYPE_STRING, 0, text);
}
Token newNumberToken(int index, num n) {
  return new Token(index, TOKEN_TYPE_NUMBER, n, "");
}
Token EOF = new Token(-1, 0, 0, "");
const $EOF = 0;
const $TAB = 9;
const $LF = 10;
const $VTAB = 11;
const $FF = 12;
const $CR = 13;
const $SPACE = 32;
const $BANG = 33;
const $DQ = 34;
const $HASH = 35;
const $$ = 36;
const $PERCENT = 37;
const $AMPERSAND = 38;
const $SQ = 39;
const $LPAREN = 40;
const $RPAREN = 41;
const $STAR = 42;
const $PLUS = 43;
const $COMMA = 44;
const $MINUS = 45;
const $PERIOD = 46;
const $SLASH = 47;
const $COLON = 58;
const $SEMICOLON = 59;
const $LT = 60;
const $EQ = 61;
const $GT = 62;
const $QUESTION = 63;
const $0 = 48;
const $9 = 57;
const $A = 65,
    $E = 69,
    $Z = 90;
const $LBRACKET = 91;
const $BACKSLASH = 92;
const $RBRACKET = 93;
const $CARET = 94;
const $_ = 95;
const $a = 97,
    $e = 101,
    $f = 102,
    $n = 110,
    $r = 114,
    $t = 116,
    $u = 117,
    $v = 118,
    $z = 122;
const $LBRACE = 123;
const $BAR = 124;
const $RBRACE = 125;
const $NBSP = 160;
class ScannerError extends Error {
  String message;
  ScannerError(message) : super() {
    /* super call moved to initializer */;
    this.message = message;
  }
  toString() {
    return this.message;
  }
}
class _Scanner {
  String input;
  int length;
  int peek;
  int index;
  _Scanner(String input) {
    this.input = input;
    this.length = input.length;
    this.peek = 0;
    this.index = -1;
    this.advance();
  }
  advance() {
    this.peek = ++this.index >= this.length
        ? $EOF
        : StringWrapper.charCodeAt(this.input, this.index);
  }
  Token scanToken() {
    var input = this.input,
        length = this.length,
        peek = this.peek,
        index = this.index; // Skip whitespace.
    while (peek <= $SPACE) {
      if (++index >= length) {
        peek = $EOF;
        break;
      } else {
        peek = StringWrapper.charCodeAt(input, index);
      }
    }
    this.peek = peek;
    this.index = index;
    if (index >= length) {
      return null;
    } // Handle identifiers and numbers.
    if (isIdentifierStart(peek)) return this.scanIdentifier();
    if (isDigit(peek)) return this.scanNumber(index);
    int start = index;
    switch (peek) {
      case $PERIOD:
        this.advance();
        return isDigit(this.peek)
            ? this.scanNumber(start)
            : newCharacterToken(start, $PERIOD);
      case $LPAREN:
      case $RPAREN:
      case $LBRACE:
      case $RBRACE:
      case $LBRACKET:
      case $RBRACKET:
      case $COMMA:
      case $COLON:
      case $SEMICOLON:
        return this.scanCharacter(start, peek);
      case $SQ:
      case $DQ:
        return this.scanString();
      case $HASH:
        return this.scanOperator(start, StringWrapper.fromCharCode(peek));
      case $PLUS:
      case $MINUS:
      case $STAR:
      case $SLASH:
      case $PERCENT:
      case $CARET:
      case $QUESTION:
        return this.scanOperator(start, StringWrapper.fromCharCode(peek));
      case $LT:
      case $GT:
      case $BANG:
      case $EQ:
        return this.scanComplexOperator(
            start, $EQ, StringWrapper.fromCharCode(peek), "=");
      case $AMPERSAND:
        return this.scanComplexOperator(start, $AMPERSAND, "&", "&");
      case $BAR:
        return this.scanComplexOperator(start, $BAR, "|", "|");
      case $NBSP:
        while (isWhitespace(this.peek)) this.advance();
        return this.scanToken();
    }
    this.error(
        '''Unexpected character [${ StringWrapper . fromCharCode ( peek )}]''',
        0);
    return null;
  }
  Token scanCharacter(int start, int code) {
    assert(this.peek == code);
    this.advance();
    return newCharacterToken(start, code);
  }
  Token scanOperator(int start, String str) {
    assert(this.peek == StringWrapper.charCodeAt(str, 0));
    assert(SetWrapper.has(OPERATORS, str));
    this.advance();
    return newOperatorToken(start, str);
  }
  Token scanComplexOperator(int start, int code, String one, String two) {
    assert(this.peek == StringWrapper.charCodeAt(one, 0));
    this.advance();
    String str = one;
    while (this.peek == code) {
      this.advance();
      str += two;
    }
    assert(SetWrapper.has(OPERATORS, str));
    return newOperatorToken(start, str);
  }
  Token scanIdentifier() {
    assert(isIdentifierStart(this.peek));
    int start = this.index;
    this.advance();
    while (isIdentifierPart(this.peek)) this.advance();
    String str = this.input.substring(start, this.index);
    if (SetWrapper.has(KEYWORDS, str)) {
      return newKeywordToken(start, str);
    } else {
      return newIdentifierToken(start, str);
    }
  }
  Token scanNumber(int start) {
    assert(isDigit(this.peek));
    bool simple = (identical(this.index, start));
    this.advance();
    while (true) {
      if (isDigit(this.peek)) {} else if (this.peek == $PERIOD) {
        simple = false;
      } else if (isExponentStart(this.peek)) {
        this.advance();
        if (isExponentSign(this.peek)) this.advance();
        if (!isDigit(this.peek)) this.error("Invalid exponent", -1);
        simple = false;
      } else {
        break;
      }
      this.advance();
    }
    String str = this.input.substring(start, this.index); // TODO
    num value = simple
        ? NumberWrapper.parseIntAutoRadix(str)
        : NumberWrapper.parseFloat(str);
    return newNumberToken(start, value);
  }
  Token scanString() {
    assert(this.peek == $SQ || this.peek == $DQ);
    int start = this.index;
    int quote = this.peek;
    this.advance();
    StringJoiner buffer;
    int marker = this.index;
    String input = this.input;
    while (this.peek != quote) {
      if (this.peek == $BACKSLASH) {
        if (buffer == null) buffer = new StringJoiner();
        buffer.add(input.substring(marker, this.index));
        this.advance();
        int unescapedCode;
        if (this.peek == $u) {
          // 4 character hex code for unicode character.
          String hex = input.substring(this.index + 1, this.index + 5);
          try {
            unescapedCode = NumberWrapper.parseInt(hex, 16);
          } catch (e) {
            this.error('''Invalid unicode escape [\\u${ hex}]''', 0);
          }
          for (int i = 0; i < 5; i++) {
            this.advance();
          }
        } else {
          unescapedCode = unescape(this.peek);
          this.advance();
        }
        buffer.add(StringWrapper.fromCharCode(unescapedCode));
        marker = this.index;
      } else if (this.peek == $EOF) {
        this.error("Unterminated quote", 0);
      } else {
        this.advance();
      }
    }
    String last = input.substring(marker, this.index);
    this.advance(); // Compute the unescaped string value.
    String unescaped = last;
    if (buffer != null) {
      buffer.add(last);
      unescaped = buffer.toString();
    }
    return newStringToken(start, unescaped);
  }
  error(String message, int offset) {
    int position = this.index + offset;
    throw new ScannerError(
        '''Lexer Error: ${ message} at column ${ position} in expression [${ this . input}]''');
  }
}
bool isWhitespace(int code) {
  return (code >= $TAB && code <= $SPACE) || (code == $NBSP);
}
bool isIdentifierStart(int code) {
  return ($a <= code && code <= $z) ||
      ($A <= code && code <= $Z) ||
      (code == $_) ||
      (code == $$);
}
bool isIdentifierPart(int code) {
  return ($a <= code && code <= $z) ||
      ($A <= code && code <= $Z) ||
      ($0 <= code && code <= $9) ||
      (code == $_) ||
      (code == $$);
}
bool isDigit(int code) {
  return $0 <= code && code <= $9;
}
bool isExponentStart(int code) {
  return code == $e || code == $E;
}
bool isExponentSign(int code) {
  return code == $MINUS || code == $PLUS;
}
int unescape(int code) {
  switch (code) {
    case $n:
      return $LF;
    case $f:
      return $FF;
    case $r:
      return $CR;
    case $t:
      return $TAB;
    case $v:
      return $VTAB;
    default:
      return code;
  }
}
var OPERATORS = SetWrapper.createFromList([
  "+",
  "-",
  "*",
  "/",
  "%",
  "^",
  "=",
  "==",
  "!=",
  "===",
  "!==",
  "<",
  ">",
  "<=",
  ">=",
  "&&",
  "||",
  "&",
  "|",
  "!",
  "?",
  "#"
]);
var KEYWORDS =
    SetWrapper.createFromList(["var", "null", "undefined", "true", "false"]);
