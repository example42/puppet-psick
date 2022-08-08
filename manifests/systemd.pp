# This profile allows triggering systemd commands once for all modules
# Based on https://github.com/voxpupuli/puppet-systemd module
#
# @api public
#
# @param default_target
#   The default systemd boot target, unmanaged if set to undef.
# @param unit_files
#   Hash of `psick::systemd::unit_file` resources
#
class psick::systemd (
  Optional[Pattern['^.+\.target$']]                   $default_target = undef,
  Hash[String[1],Hash[String[1], Any]]                $unit_files = {},

) {

  if $default_target {
    $target = shell_escape($default_target)
    service { $target:
      ensure => 'running',
      enable => true,
    }

    exec { "systemctl set-default ${target}":
      command => "systemctl set-default ${target}",
      unless  => "test $(systemctl get-default) = ${target}",
      path    => $facts['path'],
    }
  }

  $unit_files.each |$unit_file, $unit_file_data| {
    psick::systemd::unit_file { $unit_file:
      * => $unit_file_data,
    }
  }

}
