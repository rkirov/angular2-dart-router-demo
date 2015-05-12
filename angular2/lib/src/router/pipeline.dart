library angular2.src.router.pipeline;

import "package:angular2/src/facade/async.dart" show Future, PromiseWrapper;
import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "instruction.dart" show Instruction;

/**
 * Responsible for performing each step of navigation.
 * "Steps" are conceptually similar to "middleware"
 */
class Pipeline {
  List steps;
  Pipeline() {
    this.steps = [
      (instruction) => instruction
          .traverseSync((parentInstruction, childInstruction) {
        childInstruction.router =
            parentInstruction.router.childRouter(childInstruction.component);
      }),
      (instruction) => instruction.router.traverseOutlets((outlet, name) {
        return outlet.canDeactivate(instruction.getChildInstruction(name));
      }),
      (instruction) => instruction.router.traverseOutlets((outlet, name) {
        return outlet.canActivate(instruction.getChildInstruction(name));
      }),
      (instruction) => instruction.router.activateOutlets(instruction)
    ];
  }
  Future process(Instruction instruction) {
    var steps = this.steps,
        currentStep = 0;
    Future processOne([dynamic result = true]) {
      if (currentStep >= steps.length) {
        return PromiseWrapper.resolve(result);
      }
      var step = steps[currentStep];
      currentStep += 1;
      return PromiseWrapper.resolve(step(instruction)).then(processOne);
    }
    return processOne();
  }
}
