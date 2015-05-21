library angular2.src.render.dom.compiler.compile_step;

import "compile_element.dart" show CompileElement;
import "compile_control.dart" as compileControlModule;

/**
 * One part of the compile process.
 * Is guaranteed to be called in depth first order
 */
abstract class CompileStep {
  void process(CompileElement parent, CompileElement current,
      compileControlModule.CompileControl control);
}
