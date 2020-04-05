# This class manages /etc/profile and relevant files
#
# @example Create custom scripts under /etc/profile.d with files taken from
#   a local module (called profile, as in roles & profiles, ):
#
#   psick::profile::scripts_hash:
#     rvm.sh:
#       template: 'profile/profile/rvm.sh.erb'
#     ls.sh:
#       source: puppet:///modules/profile/profile/ls.sh
#
# @example Export TZ variable for system optimisation
#   psick::profile::add_tz_optimisation: true
#
# @param template The path of the erb template (as used in template())
#                           to use for the content of /etc/profile.
#                           If empty the file is not managed.
# @param scripts_hash An hash of psick::profile::script resources to create
# @param add_tz_optimisation If to automatically include a script that
#   add the TZ en variable to optimise system performance
#   https://blog.packagecloud.io/eng/2017/02/21/set-environment-variable-save-thousands-of-system-calls/
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
class psick::profile (
  String $template             = '',
  Hash $options                = {},

  Hash $scripts_hash           = {},

  Boolean $add_tz_optimisation = true,

  Boolean $manage              = $::psick::manage,
  Boolean $noop_manage         = $::psick::noop_manage,
  Boolean $noop_value          = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }


    if $template != '' {
      file { '/etc/profile':
        content => template($template),
      }
    }
    $scripts_hash.each | $k,$v | {
      psick::profile::script { $k:
        * => $v,
      }
    }

    file { '/etc/profile.d/tz.sh':
      ensure  => bool2ensure($add_tz_optimisation),
      content => template('psick/profile/tz.sh.erb'),
    }
  }
}
