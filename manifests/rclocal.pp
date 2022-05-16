# Class: psick::rclocal
#
# @summary Manages /etc/rc.local file inserting a /etc/rc.local.d/ directory where
#   each script is managaed by Puppet
#
# @example include psick::rclocal
#
# @param config_file
#   The full name and path of the rc.local file, defaults to /etc/rc.local on most operatingsystems.
#   Must be an absolute path
#
# @param config_dir
#   The directory where rc.local snippets are stored. Must be an absolute path
#
# @param template
#   The template to use to generate the rc.local file. Defaults to module template
#
# @param service_name
#   The name of the systemd service. Only used on systems with service provider systemd
#
# @param scripts
#   A hash of snippets to be added.
#   The key must be the snippet name, the values must be parameteres of the rclocal::script define.
#
class psick::rclocal (
  Stdlib::Absolutepath $config_file,
  Stdlib::Absolutepath $config_dir,
  String[1]            $template,
  Hash                 $scripts,
  String[1]            $service_name,
) {
  File {
    owner => 'root',
    group => '0',
    mode  => '0755',
  }

  file { '/etc/rc.local':
    ensure  => file,
    path    => $rclocal::config_file,
    content => epp($rclocal::template),
  }

  file { '/etc/rc.local.d':
    ensure  => directory,
    path    => $rclocal::config_dir,
    purge   => true,
    recurse => true,
  }

  ### Create instances for integration with Hiera
  if $scripts != {} {
    $scripts.each |$k, $v| {
      psick::rclocal::script { $k:
        *       => $v,
        require => File['/etc/rc.local.d'],
      }
    }
  }

  psick::systemd::unit_file { $service_name:
    ensure  => 'present',
    content => epp('psick/rclocal/systemd_rc-local.service.epp'),
    enable  => true,
    active  => true,
  }
}
