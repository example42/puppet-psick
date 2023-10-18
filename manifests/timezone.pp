# Class ::psick::::timezone
# Derived from https://github.com/example42/puppet-timezone
#
# This class manages the System's timezone
#
# Parameters:
#
# [*timezone*]
#   The timezone to use
#
# [*timezone_windows*]
#   The timezone as needed by tzutil.exe command on Windows
#
# [*hw_utc*]
#   If system clock is set to UTC. Default: false
#
# [*set_timezone_command*]
#   The command to execute to apply the new timezone.
#   Default is automatically set according to OS
#
# [*template*
#   The template to use for the timezone file.
#   Default is autocalculated for each supported OS
#
class psick::timezone (
  String $timezone             = $psick::timezone,
  String $timezone_windows     = '', # lint:ignore:params_empty_string_assignment
  Boolean $hw_utc              = false,
  String $set_timezone_command = '', # lint:ignore:params_empty_string_assignment
  String $template             = "psick/timezone/timezone-${facts['os']['name']}",

  Boolean          $manage               = $psick::manage,
  Boolean          $noop_manage          = $psick::noop_manage,
  Boolean          $noop_value           = $psick::noop_value,

) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    case $facts['os']['family'] {
      'RedHat' : {
        $redhat_command = $facts['os']['release']['major'] ? {
          /7/     => "timedatectl set-timezone ${timezone}",
          default => 'tzdata-update',
        }
      }
      'Debian' : {
        $debian_command = $facts['os']['release']['major'] ? {
          /(16.04|16.10|17.04|17.10|18.04|18.10|19.04|19.10|20.04|20.10|21.04|21.10|22.04|22.10|23.04|23.10)/ => "timedatectl set-timezone ${timezone}", # lint:ignore:140chars
          /(9|10|11|12)/ => "ln -fs /usr/share/zoneinfo/${timezone} /etc/localtime ; dpkg-reconfigure -f noninteractive tzdata",
          default        => 'dpkg-reconfigure -f noninteractive tzdata',
        }
      }
      default: {}
    }

    $real_set_timezone_command = $set_timezone_command ? {
      ''      => $facts['os']['name'] ? {
        /(?i:RedHat|Centos|Scientific|Fedora|Amazon|Linux)/ => $redhat_command,
        /(?i:Ubuntu|Debian|Mint|Raspbian)/                  => $debian_command,
        /(?i:SLES|OpenSuSE)/                                => "zic -l ${timezone}",
        /(?i:OpenBSD)/                                      => "ln -fs /usr/share/zoneinfo/${timezone} /etc/localtime",
        /(?i:FreeBSD)/                                      => "cp /usr/share/zoneinfo/${timezone} /etc/localtime && adjkerntz -a",
        /(?i:Solaris)/                                      => "rtc -z ${timezone} && rtc -c",
        /(?i:Windows)/                                      => "tzutil.exe /s \"${timezone_windows}\"",
        /(?i:Darwin)/                                       => "systemsetup -settimezone ${timezone}",
      },
      default => $set_timezone_command,
    }

    $config_file = $facts['os']['name'] ? {
      /(?i:RedHat|Centos|Scientific|Fedora|Amazon|Linux)/ => '/etc/sysconfig/clock',
      /(?i:Ubuntu|Debian|Mint)/                           => '/etc/timezone',
      /(?i:SLES|OpenSuSE)/                                => '/etc/sysconfig/clock',
      /(?i:FreeBSD|OpenBSD|Darwin)/                       => '/etc/timezone-puppet',
      /(?i:Solaris)/                                      => '/etc/default/init',
      /(?i:Windows)/                                      => 'c:\temp\timezone',
      default                                             => '',
    }

    $config_file_group = $facts['os']['name'] ? {
      /(?i:FreeBSD|OpenBSD|Darwin)/ => 'wheel',
      default                       => 'root',
    }

    if $facts['virtual'] != 'docker' and $config_file != '' {
      file { 'timezone':
        ensure  => file,
        path    => $config_file,
        mode    => '0644',
        owner   => 'root',
        group   => $config_file_group,
        content => template($template),
      }
      if $facts['processors']['isa'] != 'sparc' and $facts['kernel'] != 'SunOS' {
        exec { 'set-timezone':
          command     => $real_set_timezone_command,
          path        => $facts['path'],
          require     => File['timezone'],
          subscribe   => File['timezone'],
          refreshonly => true,
        }
      }
    }
  }
}
