# This class installs git using tp
#
# @param ensure Define if to install or remove git
#
class psick::git (
  Enum['present','absent'] $ensure       = 'present',
  Hash                     $configs_hash = {},
) {
  tp::install { 'git':
    ensure => $ensure,
  }
  $configs_hash.each |$k,$v| {
    psick::git::config { $k:
      * => $v,
    }
  }
}
