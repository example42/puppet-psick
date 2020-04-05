# This class managed system's packages updates via cron
#
# @param cron_schedule The cron schedule to use for System Updates. If not set
#                      no automatic update is done (unless use_yum_cron is true)
# @parma reboot_after_update If to automatically reboot the system after an
#                            update (when an reboot is needed)
# @param update_template The erb template to use for the update_script_path
# @param update_script_path The path of the script used for system updates
# @param use_yum_cron If to install (only on RedHat derivatives) the yum_cron
#                     package (via the ::psick::yum_cron class).
#                     If true, the other options are ignored.
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
#
class psick::update (
  String $cron_schedule        = '',
  Boolean $reboot_after_update = false,
  String $update_template      = 'psick/update/update.sh.erb',
  String $update_script_path   = '/usr/local/sbin/update.sh',
  Boolean $use_yum_cron        = false,

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $::osfamily == 'RedHat' and $use_yum_cron {
      contain ::psick::yum_cron
      file { '/etc/cron.d/system_update':
        ensure  => absent,
      }
    } else {
      # Custom update script
      if $cron_schedule != '' {
        file { '/etc/cron.d/system_update':
          ensure  => file,
          content => "# File managed by Puppet\n${cron_schedule} root ${update_script_path}\n",
        }
      } else {
        file { '/etc/cron.d/system_update':
          ensure  => absent,
        }
      }

      file { $update_script_path:
        ensure  => file,
        mode    => '0750',
        content => template($update_template),
        before  => File['/etc/cron.d/system_update'],
      }
    }
  }
}
