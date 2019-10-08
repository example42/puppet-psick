# This class installs openssh using tp
#
class psick::openssh (
  Hash                     $configs_hash  = {},
  Hash                     $keygens_hash  = {},
  Hash                     $keypairs_hash = {},
  Hash                     $keyscans_hash = {},
  String                   $module        = 'psick',
) {

  case $module {
    'psick': {
      contain ::psick::openssh::tp
    }
    'tp_profile': {
      contain ::tp_profile::openssh
    }
    default: {
      contain ::openssh
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
  $keyscans_hash.each |$k,$v| {
    psick::openssh::keyscan { $k:
      * => $v,
    }
  }
}
