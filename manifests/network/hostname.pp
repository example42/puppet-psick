# This class manages the system hostname
#
# @summary This class manages the system hostname
#
# @example
#   include psick::network::hostname
class psick::network::hostname (
  Optional[String] $hostname_file_template = undef,
  Boolean          $hostname_legacy        = false,
  Hash             $options                = {},
) {
  $hostname_default_template = $hostname_legacy ? {
    true  => "psick/network/legacy/hostname-${facts['os']['family']}.erb",
    false => "psick/network/hostname-${facts['os']['family']}.erb",
  }
  $file_template = pick($hostname_file_template,$hostname_default_template)
  $manage_hostname = pick($psick::network::hostname,$facts['networking']['fqdn'])

  if $facts['os']['family'] == 'RedHat' {
    file { '/etc/sysconfig/network':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template($file_template),
      notify  => $psick::network::manage_config_file_notify,
    }
    case $facts['os']['release']['major'] {
      '7': {
        exec { 'sethostname':
          command => "/usr/bin/hostnamectl set-hostname ${manage_hostname}",
          unless  => "/usr/bin/hostnamectl status | grep 'Static hostname: ${manage_hostname}'",
        }
      }
      default: {}
    }
  }

  if $facts['os']['family'] == 'Debian' {
    file { '/etc/hostname':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template($file_template),
      notify  => $psick::network::manage_config_file_notify,
    }
  }

  if $facts['os']['family'] == 'Suse' {
    file { '/etc/HOSTNAME':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => inline_template("<%= @manage_hostname %>\n"),
      notify  => Exec['sethostname'],
    }
    exec { 'sethostname':
      command => "/bin/hostname ${manage_hostname}",
      unless  => "/bin/hostname -f | grep ${manage_hostname}",
    }
  }

  if $facts['os']['family'] == 'Solaris' {
    file { '/etc/nodename':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => inline_template("<%= @manage_hostname %>\n"),
      notify  => Exec['sethostname'],
    }
    exec { 'sethostname':
      command => "/usr/bin/hostname ${manage_hostname}",
      unless  => "/usr/bin/hostname | /usr/bin/grep ${manage_hostname}",
    }
  }
}
