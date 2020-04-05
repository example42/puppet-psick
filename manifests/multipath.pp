# This class installs and configures multipath (only on physical servers)
#
# @param config_file_template The path of the erb template to use for the
#                             content of /etc/multipath.conf.
#                             If empty the file is not managed.
# @param user_friendly_names Defines the content of the user_friendly_names
#                            entry in multipath.conf
#
class psick::multipath (
  String $config_file_template = 'psick/multipath/multipath.conf.erb',
  String $user_friendly_names  = 'yes',

  Boolean $manage              = $::psick::manage,
  Boolean $noop_manage         = $::psick::noop_manage,
  Boolean $noop_value          = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $config_file_template != '' and $::virtual == 'physical' {
      tp::conf { 'multipath':
        content => template($config_file_template),
      }
      tp::install { 'multipath': }
    }
  }
}
