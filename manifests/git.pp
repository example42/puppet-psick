# This class installs git using tp
#
# @param ensure Define if to install or remove git
#
class psick::git (
  Enum['present','absent'] $ensure              = 'present',
  Hash                     $configs_hash        = {},
  Array                    $extra_packages_list = [],
) {
  tp::install { 'git':
    ensure => $ensure,
  }
  $configs_hash.each |$k,$v| {
    psick::git::config { $k:
      * => $v,
    }
  }
  $extra_packages_list.each |$k| {
    package { $k:
      ensure => $ensure,
    }
  }
}
