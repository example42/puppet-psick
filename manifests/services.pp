# Manages services and custom init/systemd scripts
#
# This class provides a wrapper for psick services defines
#
class psick::services (
  Optional[Hash] $init_scripts = {},
  Optional[Hash] $systemd_scripts = {},
) {
  if $::kernel == 'Linux' {
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
