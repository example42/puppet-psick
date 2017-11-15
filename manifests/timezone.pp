# Class ::psick::timezone
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
class psick::timezone(
  String $timezone             = $::psick::time::timezone,
  String $timezone_windows     = '',
  Boolean $hw_utc              = false,
  String $set_timezone_command = '',
  String $template             = "psick/timezone/timezone-${::operatingsystem}",
  ) {

  case $::osfamily {
    'RedHat' : {
      $redhat_command = $::operatingsystemmajrelease ? {
        /7/     => "timedatectl set-timezone ${timezone}",
        default => 'tzdata-update',
      }
    }
    'Debian' : {
      $debian_command = $::operatingsystemmajrelease ? {
        /16.04/ => "timedatectl set-timezone ${timezone}",
        default => 'dpkg-reconfigure -f noninteractive tzdata',
      }
    }
  }

  $real_set_timezone_command = $set_timezone_command ? {
    ''      => $::operatingsystem ? {
      /(?i:RedHat|Centos|Scientific|Fedora|Amazon|Linux)/ => $redhat_command,
      /(?i:Ubuntu|Debian|Mint)/                           => $debian_command,
      /(?i:SLES|OpenSuSE)/                                => "zic -l ${timezone}",
      /(?i:OpenBSD)/                                      => "ln -fs /usr/share/zoneinfo/${timezone} /etc/localtime",
      /(?i:FreeBSD)/                                      => "cp /usr/share/zoneinfo/${timezone} /etc/localtime && adjkerntz -a",
      /(?i:Solaris)/                                      => "rtc -z ${timezone} && rtc -c",
      /(?i:Windows)/                                      => "tzutil.exe /s \"${timezone_windows}\"",
    },
    default => $set_timezone_command,
  }

  $config_file = $::operatingsystem ? {
    /(?i:RedHat|Centos|Scientific|Fedora|Amazon|Linux)/ => '/etc/sysconfig/clock',
    /(?i:Ubuntu|Debian|Mint)/                           => '/etc/timezone',
    /(?i:SLES|OpenSuSE)/                                => '/etc/sysconfig/clock',
    /(?i:FreeBSD|OpenBSD)/                              => '/etc/timezone-puppet',
    /(?i:Solaris)/                                      => '/etc/default/init',
    /(?i:Windows)/                                      => 'c:\temp\timezone',
    default                                             => '',
  }

  $config_file_group = $::operatingsystem ? {
    /(?i:FreeBSD|OpenBSD)/ => 'wheel',
    default                => 'root',
  }

  if $::virtual != 'docker' and $config_file != '' {
    file { 'timezone':
      ensure  => file,
      path    => $config_file,
      mode    => '0644',
      owner   => 'root',
      group   => $config_file_group,
      content => template($template),
    }
    if $::hardwareisa != 'sparc' and $::kernel != 'SunOS' {
      exec { 'set-timezone':
        command     => $real_set_timezone_command,
        path        => $::path,
        require     => File['timezone'],
        subscribe   => File['timezone'],
        refreshonly => true,
      }
    }
  }
}
