# Manages services and custom init/systemd scripts
#
# This class provides a wrapper for psick services defines
#
class psick::services (
  Hash $init_scripts    = {},
  Hash $systemd_scripts = {},

  Boolean $manage                 = $psick::manage,
  Boolean $noop_manage            = $psick::noop_manage,
  Boolean $noop_value             = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $facts['kernel'] == 'Linux' {
      $init_scripts.each |$k,$v| {
        psick::services::init_script { $k:
          * => $v,
        }
      }
      $systemd_scripts.each |$k,$v| {
        psick::services::systemd_script { $k:
          * => $v,
        }
      }
    }
  }
}
