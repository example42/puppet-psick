# @summary Manages loading and configuration of a Linux kernel module
#
# This define manages the loading of a module, via modprobe and its
# configuration in /etc/modprobe.d/$title.conf
#
# @example
#   psick::kmod::module { 'bonding': }
define psick::kmod::module (
  Enum['present','absent'] $ensure = 'present',
  String $module                   = $title,
  Optional[String] $conf_source    = undef,
  Optional[String] $conf_content   = undef,
  Optional[Hash] $conf_options     = {},
  Boolean $boot_load_configure     = true,
) {

  if $conf_source or $conf_content {
    file { "/etc/modprobe.d/${title}.conf":
      ensure  => $ensure,
      source  => $conf_source,
      content => $conf_content,
    }
  }

  case $ensure {
    'present': {
      exec { "modprobe ${title}":
        command => "modprobe ${module}",
        path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        unless  => "egrep -q '^${module} ' /proc/modules",
      }
    }

    'absent': {
      exec { "modprobe -r ${title}":
        command => "modprobe -r ${module}",
        path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        onlyif  => "egrep -q '^${module} ' /proc/modules",
      }
    }
    default: { }
  }

  if $boot_load_configure {
    if $facts['service_provider'] == 'systemd' {
      file { "/etc/modules-load.d/${title}.conf":
        ensure  => $ensure,
        mode    => '0644',
        content => "# File is managed by Puppet via psick::kmod::module \n${module}\n",
      }
    } else {
      case $::osfamily {
        'Debian': {
          file_line { "kernel load ${title}":
            ensure => $ensure,
            path   => '/etc/kernel',
            line   => $module,
            match  => "^${module}",
          }
        }
        'RedHat': {
          file { "/etc/sysconfig/modules/${title}.modules":
            ensure  => $ensure,
            mode    => '0755',
            content => "#!/bin/bash \nexec /sbin/modprode ${module} > /dev/null 2>&1\n",
          }
        }
        'Suse': {
          file_line { "kernel load ${title}":
            ensure => $ensure,
            path   => '/etc/sysconfig/kernel',
            line   => "MODULES_LOADED_ON_BOOT=${module}",
            match  => "^MODULES_LOADED_ON_BOOT=${module}",
          }
        }
        default: { }
      }
    }
  }
}
