library angular2.src.core.compiler.directive_metadata_reader;

import "package:angular2/di.dart" show Injector;
import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/lang.dart"
    show Type, isPresent, BaseException, stringify;
import "../annotations_impl/annotations.dart" show Directive, Component;
import "directive_metadata.dart" show DirectiveMetadata;
import "package:angular2/src/reflection/reflection.dart" show reflector;

@Injectable()
class DirectiveMetadataReader {
  DirectiveMetadata read(Type type) {
    var annotations = reflector.annotations(type);
    if (isPresent(annotations)) {
      for (var i = 0; i < annotations.length; i++) {
        var annotation = annotations[i];
        if (annotation is Directive) {
          var resolvedInjectables = null;
          if (annotation is Component && isPresent(annotation.injectables)) {
            resolvedInjectables = Injector.resolve(annotation.injectables);
          }
          return new DirectiveMetadata(type, annotation, resolvedInjectables);
        }
      }
    }
    throw new BaseException(
        '''No Directive annotation found on ${ stringify ( type )}''');
  }
}
