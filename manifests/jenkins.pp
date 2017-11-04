# @class jenkins
#
class psick::jenkins (

  Variant[Boolean,String]    $ensure     = 'present',
  Enum['psick']              $module     = 'psick',

  Hash                       $plugins    = {},
) {

  # Intallation management
  case $module {
    'psick': {
      contain ::psick::java
      contain ::psick::jenkins::tp
      $plugins.each |$k,$v| {
        psick::jenkins::plugin { $k:
         * => $v,
        }
      }
    }
    default: {
      contain ::jenkins
    }
  }

}
