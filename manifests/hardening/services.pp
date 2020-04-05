# Generic class to remove unnecessary services
#
# @param services_to_remove List of services to disable
# @param services_default Default list, OS dependent, of services to disable
# @param remove_default_services If to remove the services_default
#
# @example Disable rpcbind service
#   psick::hardening::services::services_to_remove:
#     - rpcbind
#
class psick::hardening::services (
  Array $services_to_remove,
  Array $services_default,
  Boolean $remove_default_services = true,
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $services = $remove_default_services ? {
      true  => $services_to_remove + $services_default,
      false => $services_to_remove,
    }

    $services.each |$pkg| {
      service { $pkg:
        ensure => stopped,
        enable => false,
      }
    }
  }
}
