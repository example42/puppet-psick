# GWs validator. We need it to have compatibility with puppet 3.x, 'cause it doesn't support each.
#
define psick::network::validate_gw (Any $routes) {
  $route = $routes[$name]
}
