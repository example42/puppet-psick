# Class psick::oracle
# Manages Oracle prerequisites and eventually installation (via oradb module)
# By default psick::oracle does nothing, besides includig a common settings
# class and exposing params to include the classes that manage oracle prerequisites,
# installation and generation of databases and other resources.
#
# @param prerequisites_class Name of the class that installs Oracle
#                            prerequisites. Must be defined.
# @param install_class Name of the class that installs Oracle (via oradb module)
# @param resources_class Name of the class that installs extra Oracle resources
# @param instances An hash of oracle instances to create (uses
#                  psick::oracle::instance)
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed. Default value is taken from main psick class.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class). Default from psick class.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#                   Default from psick class.
class psick::oracle (
  String $prerequisites_class = '::psick::oracle::prerequisites',
  String $install_class       = '',
  String $resources_class     = '',
  Hash $instances             = { },

  Boolean $manage             = $::psick::manage,
  Boolean $noop_manage        = $::psick::noop_manage,
  Boolean $noop_value         = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    contain ::psick::oracle::params

    if $prerequisites_class != '' {
      contain $prerequisites_class
    }
    if $install_class != '' {
      contain $install_class
      Class[$prerequisites_class] -> Class[$install_class]
    }
    if $resources_class != '' {
      contain $resources_class
      Class[$prerequisites_class] -> Class[$install_class] -> Class[$resources_class]
    }

    $instances.each |$k,$o| {
      psick::oracle::instance { $k:
        require => Class[$install_class],
        *       => $o,
      }
    }
  }
}
