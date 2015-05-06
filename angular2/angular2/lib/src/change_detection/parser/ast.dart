library angular2.src.change_detection.parser.ast;

import "package:angular2/src/facade/lang.dart"
    show autoConvertAdd, isBlank, isPresent, FunctionWrapper, BaseException;
import "package:angular2/src/facade/collection.dart"
    show List, Map, ListWrapper, StringMapWrapper;

class AST {
  eval(context, locals) {
    throw new BaseException("Not supported");
  }
  bool get isAssignable {
    return false;
  }
  assign(context, locals, value) {
    throw new BaseException("Not supported");
  }
  visit(visitor) {}
  String toString() {
    return "AST";
  }
}
class EmptyExpr extends AST {
  eval(context, locals) {
    return null;
  }
  visit(visitor) {}
}
class ImplicitReceiver extends AST {
  eval(context, locals) {
    return context;
  }
  visit(visitor) {
    return visitor.visitImplicitReceiver(this);
  }
} /**
 * Multiple expressions separated by a semicolon.
 */
class Chain extends AST {
  List expressions;
  Chain(List expressions) : super() {
    /* super call moved to initializer */;
    this.expressions = expressions;
  }
  eval(context, locals) {
    var result;
    for (var i = 0; i < this.expressions.length; i++) {
      var last = this.expressions[i].eval(context, locals);
      if (isPresent(last)) result = last;
    }
    return result;
  }
  visit(visitor) {
    return visitor.visitChain(this);
  }
}
class Conditional extends AST {
  AST condition;
  AST trueExp;
  AST falseExp;
  Conditional(AST condition, AST trueExp, AST falseExp) : super() {
    /* super call moved to initializer */;
    this.condition = condition;
    this.trueExp = trueExp;
    this.falseExp = falseExp;
  }
  eval(context, locals) {
    if (this.condition.eval(context, locals)) {
      return this.trueExp.eval(context, locals);
    } else {
      return this.falseExp.eval(context, locals);
    }
  }
  visit(visitor) {
    return visitor.visitConditional(this);
  }
}
class AccessMember extends AST {
  AST receiver;
  String name;
  Function getter;
  Function setter;
  AccessMember(AST receiver, String name, Function getter, Function setter)
      : super() {
    /* super call moved to initializer */;
    this.receiver = receiver;
    this.name = name;
    this.getter = getter;
    this.setter = setter;
  }
  eval(context, locals) {
    if (this.receiver is ImplicitReceiver &&
        isPresent(locals) &&
        locals.contains(this.name)) {
      return locals.get(this.name);
    } else {
      var evaluatedReceiver = this.receiver.eval(context, locals);
      return this.getter(evaluatedReceiver);
    }
  }
  bool get isAssignable {
    return true;
  }
  assign(context, locals, value) {
    var evaluatedContext = this.receiver.eval(context, locals);
    if (this.receiver is ImplicitReceiver &&
        isPresent(locals) &&
        locals.contains(this.name)) {
      throw new BaseException(
          '''Cannot reassign a variable binding ${ this . name}''');
    } else {
      return this.setter(evaluatedContext, value);
    }
  }
  visit(visitor) {
    return visitor.visitAccessMember(this);
  }
}
class KeyedAccess extends AST {
  AST obj;
  AST key;
  KeyedAccess(AST obj, AST key) : super() {
    /* super call moved to initializer */;
    this.obj = obj;
    this.key = key;
  }
  eval(context, locals) {
    var obj = this.obj.eval(context, locals);
    var key = this.key.eval(context, locals);
    return obj[key];
  }
  bool get isAssignable {
    return true;
  }
  assign(context, locals, value) {
    var obj = this.obj.eval(context, locals);
    var key = this.key.eval(context, locals);
    obj[key] = value;
    return value;
  }
  visit(visitor) {
    return visitor.visitKeyedAccess(this);
  }
}
class Pipe extends AST {
  AST exp;
  String name;
  List<AST> args;
  bool inBinding;
  Pipe(AST exp, String name, List args, bool inBinding) : super() {
    /* super call moved to initializer */;
    this.exp = exp;
    this.name = name;
    this.args = args;
    this.inBinding = inBinding;
  }
  visit(visitor) {
    return visitor.visitPipe(this);
  }
}
class LiteralPrimitive extends AST {
  var value;
  LiteralPrimitive(value) : super() {
    /* super call moved to initializer */;
    this.value = value;
  }
  eval(context, locals) {
    return this.value;
  }
  visit(visitor) {
    return visitor.visitLiteralPrimitive(this);
  }
}
class LiteralArray extends AST {
  List expressions;
  LiteralArray(List expressions) : super() {
    /* super call moved to initializer */;
    this.expressions = expressions;
  }
  eval(context, locals) {
    return ListWrapper.map(this.expressions, (e) => e.eval(context, locals));
  }
  visit(visitor) {
    return visitor.visitLiteralArray(this);
  }
}
class LiteralMap extends AST {
  List keys;
  List values;
  LiteralMap(List keys, List values) : super() {
    /* super call moved to initializer */;
    this.keys = keys;
    this.values = values;
  }
  eval(context, locals) {
    var res = StringMapWrapper.create();
    for (var i = 0; i < this.keys.length; ++i) {
      StringMapWrapper.set(
          res, this.keys[i], this.values[i].eval(context, locals));
    }
    return res;
  }
  visit(visitor) {
    return visitor.visitLiteralMap(this);
  }
}
class Interpolation extends AST {
  List strings;
  List expressions;
  Interpolation(List strings, List expressions) : super() {
    /* super call moved to initializer */;
    this.strings = strings;
    this.expressions = expressions;
  }
  eval(context, locals) {
    throw new BaseException("evaluating an Interpolation is not supported");
  }
  visit(visitor) {
    visitor.visitInterpolation(this);
  }
}
class Binary extends AST {
  String operation;
  AST left;
  AST right;
  Binary(String operation, AST left, AST right) : super() {
    /* super call moved to initializer */;
    this.operation = operation;
    this.left = left;
    this.right = right;
  }
  eval(context, locals) {
    var left = this.left.eval(context, locals);
    switch (this.operation) {
      case "&&":
        return left && this.right.eval(context, locals);
      case "||":
        return left || this.right.eval(context, locals);
    }
    var right = this.right.eval(context, locals);
    switch (this.operation) {
      case "+":
        return left + right;
      case "-":
        return left - right;
      case "*":
        return left * right;
      case "/":
        return left / right;
      case "%":
        return left % right;
      case "==":
        return left == right;
      case "!=":
        return left != right;
      case "===":
        return identical(left, right);
      case "!==":
        return !identical(left, right);
      case "<":
        return left < right;
      case ">":
        return left > right;
      case "<=":
        return left <= right;
      case ">=":
        return left >= right;
      case "^":
        return left ^ right;
      case "&":
        return left & right;
    }
    throw "Internal error [\$operation] not handled";
  }
  visit(visitor) {
    return visitor.visitBinary(this);
  }
}
class PrefixNot extends AST {
  AST expression;
  PrefixNot(AST expression) : super() {
    /* super call moved to initializer */;
    this.expression = expression;
  }
  eval(context, locals) {
    return !this.expression.eval(context, locals);
  }
  visit(visitor) {
    return visitor.visitPrefixNot(this);
  }
}
class Assignment extends AST {
  AST target;
  AST value;
  Assignment(AST target, AST value) : super() {
    /* super call moved to initializer */;
    this.target = target;
    this.value = value;
  }
  eval(context, locals) {
    return this.target.assign(
        context, locals, this.value.eval(context, locals));
  }
  visit(visitor) {
    return visitor.visitAssignment(this);
  }
}
class MethodCall extends AST {
  AST receiver;
  Function fn;
  List args;
  String name;
  MethodCall(AST receiver, String name, Function fn, List args) : super() {
    /* super call moved to initializer */;
    this.receiver = receiver;
    this.fn = fn;
    this.args = args;
    this.name = name;
  }
  eval(context, locals) {
    var evaluatedArgs = evalList(context, locals, this.args);
    if (this.receiver is ImplicitReceiver &&
        isPresent(locals) &&
        locals.contains(this.name)) {
      var fn = locals.get(this.name);
      return FunctionWrapper.apply(fn, evaluatedArgs);
    } else {
      var evaluatedReceiver = this.receiver.eval(context, locals);
      return this.fn(evaluatedReceiver, evaluatedArgs);
    }
  }
  visit(visitor) {
    return visitor.visitMethodCall(this);
  }
}
class FunctionCall extends AST {
  AST target;
  List args;
  FunctionCall(AST target, List args) : super() {
    /* super call moved to initializer */;
    this.target = target;
    this.args = args;
  }
  eval(context, locals) {
    var obj = this.target.eval(context, locals);
    if (!(obj is Function)) {
      throw new BaseException('''${ obj} is not a function''');
    }
    return FunctionWrapper.apply(obj, evalList(context, locals, this.args));
  }
  visit(visitor) {
    return visitor.visitFunctionCall(this);
  }
}
class ASTWithSource extends AST {
  AST ast;
  String source;
  String location;
  ASTWithSource(AST ast, String source, String location) : super() {
    /* super call moved to initializer */;
    this.source = source;
    this.location = location;
    this.ast = ast;
  }
  eval(context, locals) {
    return this.ast.eval(context, locals);
  }
  bool get isAssignable {
    return this.ast.isAssignable;
  }
  assign(context, locals, value) {
    return this.ast.assign(context, locals, value);
  }
  visit(visitor) {
    return this.ast.visit(visitor);
  }
  String toString() {
    return '''${ this . source} in ${ this . location}''';
  }
}
class TemplateBinding {
  String key;
  bool keyIsVar;
  String name;
  ASTWithSource expression;
  TemplateBinding(
      String key, bool keyIsVar, String name, ASTWithSource expression) {
    this.key = key;
    this.keyIsVar = keyIsVar; // only either name or expression will be filled.
    this.name = name;
    this.expression = expression;
  }
} //INTERFACE
class AstVisitor {
  visitAccessMember(AccessMember ast) {}
  visitAssignment(Assignment ast) {}
  visitBinary(Binary ast) {}
  visitChain(Chain ast) {}
  visitConditional(Conditional ast) {}
  visitPipe(Pipe ast) {}
  visitFunctionCall(FunctionCall ast) {}
  visitImplicitReceiver(ImplicitReceiver ast) {}
  visitKeyedAccess(KeyedAccess ast) {}
  visitLiteralArray(LiteralArray ast) {}
  visitLiteralMap(LiteralMap ast) {}
  visitLiteralPrimitive(LiteralPrimitive ast) {}
  visitMethodCall(MethodCall ast) {}
  visitPrefixNot(PrefixNot ast) {}
}
class AstTransformer {
  visitImplicitReceiver(ImplicitReceiver ast) {
    return ast;
  }
  visitInterpolation(Interpolation ast) {
    return new Interpolation(ast.strings, this.visitAll(ast.expressions));
  }
  visitLiteralPrimitive(LiteralPrimitive ast) {
    return new LiteralPrimitive(ast.value);
  }
  visitAccessMember(AccessMember ast) {
    return new AccessMember(
        ast.receiver.visit(this), ast.name, ast.getter, ast.setter);
  }
  visitMethodCall(MethodCall ast) {
    return new MethodCall(
        ast.receiver.visit(this), ast.name, ast.fn, this.visitAll(ast.args));
  }
  visitFunctionCall(FunctionCall ast) {
    return new FunctionCall(ast.target.visit(this), this.visitAll(ast.args));
  }
  visitLiteralArray(LiteralArray ast) {
    return new LiteralArray(this.visitAll(ast.expressions));
  }
  visitLiteralMap(LiteralMap ast) {
    return new LiteralMap(ast.keys, this.visitAll(ast.values));
  }
  visitBinary(Binary ast) {
    return new Binary(
        ast.operation, ast.left.visit(this), ast.right.visit(this));
  }
  visitPrefixNot(PrefixNot ast) {
    return new PrefixNot(ast.expression.visit(this));
  }
  visitConditional(Conditional ast) {
    return new Conditional(ast.condition.visit(this), ast.trueExp.visit(this),
        ast.falseExp.visit(this));
  }
  visitPipe(Pipe ast) {
    return new Pipe(
        ast.exp.visit(this), ast.name, this.visitAll(ast.args), ast.inBinding);
  }
  visitKeyedAccess(KeyedAccess ast) {
    return new KeyedAccess(ast.obj.visit(this), ast.key.visit(this));
  }
  visitAll(List asts) {
    var res = ListWrapper.createFixedSize(asts.length);
    for (var i = 0; i < asts.length; ++i) {
      res[i] = asts[i].visit(this);
    }
    return res;
  }
}
var _evalListCache = [
  [],
  [0],
  [0, 0],
  [0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0]
];
evalList(context, locals, List exps) {
  var length = exps.length;
  if (length > 10) {
    throw new BaseException("Cannot have more than 10 argument");
  }
  var result = _evalListCache[length];
  for (var i = 0; i < length; i++) {
    result[i] = exps[i].eval(context, locals);
  }
  return result;
}
