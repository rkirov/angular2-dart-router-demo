library angular2.src.change_detection.pipes.pipe_registry;

import "package:angular2/src/facade/collection.dart" show List, ListWrapper;
import "package:angular2/src/facade/lang.dart"
    show isBlank, isPresent, BaseException;
import "pipe.dart" show Pipe;
import "package:angular2/src/di/decorators.dart" show Injectable;
import "../change_detector_ref.dart" show ChangeDetectorRef;

@Injectable()
class PipeRegistry {
  var config;
  PipeRegistry(this.config) {}
  Pipe get(String type, obj, ChangeDetectorRef cdRef) {
    var listOfConfigs = this.config[type];
    if (isBlank(listOfConfigs)) {
      throw new BaseException(
          '''Cannot find \'${ type}\' pipe supporting object \'${ obj}\'''');
    }
    var matchingConfig = ListWrapper.find(
        listOfConfigs, (pipeConfig) => pipeConfig.supports(obj));
    if (isBlank(matchingConfig)) {
      throw new BaseException(
          '''Cannot find \'${ type}\' pipe supporting object \'${ obj}\'''');
    }
    return matchingConfig.create(cdRef);
  }
}
