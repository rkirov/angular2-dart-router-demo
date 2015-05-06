library angular2.src.mock.vm_turn_zone_mock;

import "package:angular2/src/core/zone/vm_turn_zone.dart" show VmTurnZone;

class MockVmTurnZone extends VmTurnZone {
  MockVmTurnZone() : super(enableLongStackTrace: false) {
    /* super call moved to initializer */;
  }
  run(fn) {
    fn();
  }
  runOutsideAngular(fn) {
    return fn();
  }
}
