/**
 * @module
 * @public
 * @description
 * The `di` module provides dependency injection container services.
 */
library angular2.di;

export "src/di/annotations.dart";
export "src/di/decorators.dart";
export "src/di/injector.dart" show Injector;
export "src/di/binding.dart" show Binding, ResolvedBinding, Dependency, bind;
export "src/di/key.dart" show Key, KeyRegistry;
export "src/di/exceptions.dart"
    show
        KeyMetadataError,
        NoBindingError,
        AbstractBindingError,
        AsyncBindingError,
        CyclicDependencyError,
        InstantiationError,
        InvalidBindingError,
        NoAnnotationError;
export "src/di/opaque_token.dart" show OpaqueToken;
