# class psick::puppet::postrun
# This class manages the puppet.conf's postrun_command
# configuration entry, end the content (or source) of
# the command itself
#
class psick::puppet::postrun (
  String $puppet_conf_path,
  Psick::Ensure $ensure      = present,
  Optional[String] $command  = undef,
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Optional[String] $template = undef,
  Optional[String] $epp      = undef,
  Optional[String] $path     = undef,
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $manage_content = tp_content($content, $template, $epp)

    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }
    Ini_setting {
      ensure  => $ensure,
      path    => $puppet_conf_path,
      section => 'agent',
      setting => 'postrun_command',
    }
    if $command {
      ini_setting { 'puppet_postrun_command':
        value  => $command,
      }
    }
    if $path {
      file { $path:
        content => $manage_content,
        source  => $source,
        mode    => '0755',
      }
    }
  }
}
