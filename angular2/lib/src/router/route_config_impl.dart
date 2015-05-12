library angular2.src.router.route_config_impl;

import "package:angular2/src/facade/collection.dart" show List, Map;

/**
 * You use the RouteConfig annotation to add routes to a component.
 *
 * Supported keys:
 * - `path` (required)
 * - `component`, `components`, `redirectTo` (requires exactly one of these)
 * - `as` (optional)
 */
class RouteConfig {
  final List<Map> configs;
  const RouteConfig(List<Map> configs) : configs = configs;
}
