# @class openswan
#
class psick::openswan (

  Variant[Boolean,String]    $ensure         = 'present',
  Enum['psick']              $module         = 'psick',

  Hash                       $connections    = {},
  Hash                       $setup_options  = {},
  String                     $setup_template = 'psick/openswan/ipsec.conf.erb',
) {

  # Intallation management
  case $module {
    'psick': {
      contain ::psick::openswan::tp
      $connections.each |$k,$v| {
        psick::openswan::connection { $k:
          * => $v,
        }
      }
      $content = template($setup_template)
      tp::conf { 'openswan':
        content => $content,
      }
    }
    default: {
      contain ::openswan
    }
  }

}
