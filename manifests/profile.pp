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
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides any noop setting which might be in place.
# @param manage If to actually manage any resource in this profile or not
#
class psick::profile (
  String $template   = '',
  Hash $options      = {},

  Hash $scripts_hash = {},

  Boolean $add_tz_optimisation = true,

  Boolean $manage = $::psick::manage,
  Boolean $no_noop = false,
) {

  if $manage {
    # If no_noop is set it's enforced, unless psick::noop_mode is
    if ! $::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::profile')
      noop(false)
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
