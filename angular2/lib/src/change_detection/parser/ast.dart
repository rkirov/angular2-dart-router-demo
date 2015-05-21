library angular2.src.change_detection.parser.ast;

import "package:angular2/src/facade/lang.dart"
    show isBlank, isPresent, FunctionWrapper, BaseException;
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
  dynamic visit(visitor) {
    return null;
  }
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
}
/**
 * Multiple expressions separated by a semicolon.
 */
class Chain extends AST {
  List<dynamic> expressions;
  Chain(this.expressions) : super() {
    /* super call moved to initializer */;
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
  Conditional(this.condition, this.trueExp, this.falseExp) : super() {
    /* super call moved to initializer */;
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
  AccessMember(this.receiver, this.name, this.getter, this.setter) : super() {
    /* super call moved to initializer */;
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
  KeyedAccess(this.obj, this.key) : super() {
    /* super call moved to initializer */;
  }
  eval(context, locals) {
    dynamic obj = this.obj.eval(context, locals);
    dynamic key = this.key.eval(context, locals);
    return obj[key];
  }
  bool get isAssignable {
    return true;
  }
  assign(context, locals, value) {
    dynamic obj = this.obj.eval(context, locals);
    dynamic key = this.key.eval(context, locals);
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
  List<dynamic> args;
  bool inBinding;
  Pipe(this.exp, this.name, this.args, this.inBinding) : super() {
    /* super call moved to initializer */;
  }
  visit(visitor) {
    return visitor.visitPipe(this);
  }
}
class LiteralPrimitive extends AST {
  var value;
  LiteralPrimitive(this.value) : super() {
    /* super call moved to initializer */;
  }
  eval(context, locals) {
    return this.value;
  }
  visit(visitor) {
    return visitor.visitLiteralPrimitive(this);
  }
}
class LiteralArray extends AST {
  List<dynamic> expressions;
  LiteralArray(this.expressions) : super() {
    /* super call moved to initializer */;
  }
  eval(context, locals) {
    return ListWrapper.map(this.expressions, (e) => e.eval(context, locals));
  }
  visit(visitor) {
    return visitor.visitLiteralArray(this);
  }
}
class LiteralMap extends AST {
  List<dynamic> keys;
  List<dynamic> values;
  LiteralMap(this.keys, this.values) : super() {
    /* super call moved to initializer */;
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
  List<dynamic> strings;
  List<dynamic> expressions;
  Interpolation(this.strings, this.expressions) : super() {
    /* super call moved to initializer */;
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
  Binary(this.operation, this.left, this.right) : super() {
    /* super call moved to initializer */;
  }
  eval(context, locals) {
    dynamic left = this.left.eval(context, locals);
    switch (this.operation) {
      case "&&":
        return left && this.right.eval(context, locals);
      case "||":
        return left || this.right.eval(context, locals);
    }
    dynamic right = this.right.eval(context, locals);
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
  PrefixNot(this.expression) : super() {
    /* super call moved to initializer */;
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
  Assignment(this.target, this.value) : super() {
    /* super call moved to initializer */;
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
  String name;
  Function fn;
  List<dynamic> args;
  MethodCall(this.receiver, this.name, this.fn, this.args) : super() {
    /* super call moved to initializer */;
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
  List<dynamic> args;
  FunctionCall(this.target, this.args) : super() {
    /* super call moved to initializer */;
  }
  eval(context, locals) {
    dynamic obj = this.target.eval(context, locals);
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
  ASTWithSource(this.ast, this.source, this.location) : super() {
    /* super call moved to initializer */;
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
  TemplateBinding(this.key, this.keyIsVar, this.name, this.expression) {}
}
// INTERFACE
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
  visitAll(List<dynamic> asts) {
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
evalList(context, locals, List<dynamic> exps) {
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
