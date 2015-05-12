/**
 * @module
 * @public
 * @description
 * Maps application URLs into application states, to support deep-linking and navigation.
 */
library angular2.router;

export "src/router/router.dart" show Router;
export "src/router/router_outlet.dart" show RouterOutlet;
export "src/router/router_link.dart" show RouterLink;
export "src/router/instruction.dart" show RouteParams;
export "src/router/route_config_annotation.dart";
export "src/router/route_config_decorator.dart";
import "src/router/browser_location.dart" show BrowserLocation;
import "src/router/router.dart" show Router, RootRouter;
import "src/router/route_registry.dart" show RouteRegistry;
import "src/router/pipeline.dart" show Pipeline;
import "src/router/location.dart" show Location;
import "src/core/application_tokens.dart" show appComponentAnnotatedTypeToken;
import "di.dart" show bind;

List routerInjectables = [
  RouteRegistry,
  Pipeline,
  BrowserLocation,
  Location,
  bind(Router).toFactory((registry, pipeline, location, meta) {
    return new RootRouter(registry, pipeline, location, meta.type);
  }, [RouteRegistry, Pipeline, Location, appComponentAnnotatedTypeToken])
];
