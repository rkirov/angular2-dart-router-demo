/**
 * @module
 * @public
 * @description
 * The `di` module provides dependency injection container services.
 */
library angular2.di;

export "src/di/annotations.dart";
export "src/di/decorators.dart";
export "src/di/forward_ref.dart";
export "src/di/injector.dart" show resolveBindings, Injector;
export "src/di/binding.dart" show Binding, ResolvedBinding, Dependency, bind;
export "src/di/key.dart" show Key, KeyRegistry, TypeLiteral;
export "src/di/exceptions.dart"
    show
        NoBindingError,
        AbstractBindingError,
        AsyncBindingError,
        CyclicDependencyError,
        InstantiationError,
        InvalidBindingError,
        NoAnnotationError;
export "src/di/opaque_token.dart" show OpaqueToken;
