# This class manages tp::test for PE Console
#
class psick::puppet::pe_console (
  Boolean $manage                  = $psick::manage,
  Boolean $noop_manage             = $psick::noop_manage,
  Boolean $noop_value              = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $nginx_settings = {
      package_name => 'pe-nginx',
      service_name => 'pe-nginx',
    }
    tp::test { 'nginx': settings_hash => $nginx_settings }
  }
}
