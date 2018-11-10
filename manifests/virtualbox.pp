# @class virtualbox
#
class psick::virtualbox (

  Variant[Boolean,String]    $ensure = present,
  Enum['psick']              $module = 'psick',

  Optional[Psick::Password]  $root_password = undef,

  Hash                       $network_hash  = {},
  Hash                       $vm_hash    = {},
) {

  # Intallation management
  case $module {
    'psick': {
      contain psick::virtualbox::tp
      $vm_hash.each |$k,$v| {
        psick::virtualbox::vm { $k:
          * => $v,
        }
      }
      $network_hash.each |$k,$v| {
        psick::virtualbox::network { $k:
          * => $v,
        }
      }
    }
    default: {
      contain ::virtualbox
    }
  }

}
