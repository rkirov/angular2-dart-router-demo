/**
 * @module
 * @public
 * @description
 * Define angular core API here.
 */
library angular2.core;

export "src/core/annotations/visibility.dart";
export "src/core/annotations/view.dart";
export "src/core/application.dart";
export "src/core/application_tokens.dart";
export "src/core/annotations/di.dart";
export "src/core/compiler/query_list.dart";
export "src/core/compiler/compiler.dart";
// TODO(tbosch): remove this once render migration is complete
export "src/render/dom/compiler/template_loader.dart";
export "src/render/dom/shadow_dom/shadow_dom_strategy.dart";
export "src/render/dom/shadow_dom/native_shadow_dom_strategy.dart";
export "src/render/dom/shadow_dom/emulated_scoped_shadow_dom_strategy.dart";
export "src/render/dom/shadow_dom/emulated_unscoped_shadow_dom_strategy.dart";
export "src/core/compiler/dynamic_component_loader.dart";
export "src/core/compiler/view_ref.dart" show ViewRef, ProtoViewRef;
export "src/core/compiler/view_container_ref.dart" show ViewContainerRef;
export "src/core/compiler/element_ref.dart" show ElementRef;
