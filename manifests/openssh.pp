# This class installs openssh using tp
#
# @param ensure Define if to install or remove openssh
#
class psick::openssh (
  Enum['present','absent'] $ensure        = 'present',
  Hash                     $configs_hash  = {},
  Hash                     $keygens_hash  = {},
  Hash                     $keypairs_hash = {},
  String                   $module        = 'psick',
  Boolean                  $use_tp        = true,
) {

  case $module {
    'psick': {
      if $use_tp {
        tp::install { 'openssh':
          ensure => $ensure,
        }
      }
      $configs_hash.each |$k,$v| {
        psick::openssh::config { $k:
          * => $v,
        }
      }
      $keygens_hash.each |$k,$v| {
        psick::openssh::keygen { $k:
          * => $v,
        }
      }
      $keypairs_hash.each |$k,$v| {
        psick::openssh::keypair { $k:
          * => $v,
        }
      }
    }
    default: {
      contain ::openssh
    }
  }
}
