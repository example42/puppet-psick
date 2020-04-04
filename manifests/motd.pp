# This class manages /etc/motd and /etc/issue files.
#
# @param motd_file_ensure If to create or remove /etc/motd
# @param motd_file_template The path of the erb template (as used in template())
#                           to use for the content of /etc/motd.
#                           If empty the file is not managed.
# @param motd_file_extratext A custom extra string to add at the end of the
#                            default template of /etc/motd
# @param issue_file_ensure If to create or remove /etc/issue
# @param issue_file_template The path of the erb template (as used in template())
#                            to use for the content of /etc/issue
#                            If empty the file is not managed.
# @param issue_file_extratext A custom extra string to add at the end of the
#                             default template of /etc/issue
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
class psick::motd (
  String $motd_file_ensure    = 'present',
  String $motd_file_template  = 'psick/motd/motd.erb',
  String $motd_extratext      = '',

  String $issue_file_ensure   = 'present',
  String $issue_file_template = 'psick/motd/issue.erb',
  String $issue_extratext     = '',

  Boolean $manage             = $::psick::manage,
  Boolean $noop_manage        = $::psick::noop_manage,
  Boolean $noop_value         = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $motd_file_template != '' {
      file { '/etc/motd':
        ensure  => $motd_file_ensure,
        content => template($motd_file_template),
      }
    }
    if $issue_file_template != '' {
      file { '/etc/issue':
        ensure  => $issue_file_ensure,
        content => template($issue_file_template),
      }
    }
  }
}
