#
# = Define: psick::network::interface
#
# This define manages interfaces.
# Currently only Debian and RedHat families supported.
#
# == Common parameters
#
# $enable_dhcp
#   Boolean. Default: false
#   Activates DHCP on the interface
#
# [*ipaddress*]
# [*netmask*]
# [*broadcast*]
# [*hwaddr*]
#   String. Default: undef
#   Standard network parameters
#
# [*enable*]
#   Boolean. Default: true
#   Manages the interface presence. Possible values:
#   * true   - Interface created and enabled at boot.
#   * false  - Interface removed from boot.
#
# [*template*]
#   String. Optional. Default: Managed by module.
#   Provide an alternative custom template to use for configuration of:
#   - On Debian: file fragments in /etc/network/interfaces
#   - On RedHat: files /etc/sysconfig/network-scripts/ifcfg-${name}
#   You can copy and adapt network/templates/interface/${::osfamily}.erb
#
# [*restart_all_nic*]
#   Boolean. Default: true
#   Manages the way to apply interface creation/modification:
#   - If true, will trigger a restart of all network interfaces
#   - If false, will only start/restart this specific interface
#
# [*reload_command*]
#   String. Default: $::operatingsystem ? {'CumulusLinux' => 'ifreload -a',
#                                          default        => "ifdown ${interface}; ifup ${interface}",
#                                         }
#   Defines the command(s) that will be used to reload a nic when restart_all_nic
#   is set to false
#
# [*options*]
#   A generic hash of custom options that can be used in a custom template
#
# [*description*]
#   String. Optional. Default: undef
#   Adds comment with given description in file before interface declaration.
#
define psick::network::interface (

  Boolean $enable                  = true,
  Enum['present','absent'] $ensure = 'present',
  String $template                 = "psick/network/interface/${::osfamily}.erb",
  Hash $options                    = {},
  String $interface                = $title,
  Boolean $restart_all_nic         = true,
  Optional[String]$reload_command  = undef,

  Boolean $enable_dhcp             = false,

  ) {

  # Resources
  $real_reload_command = $reload_command ? {
    undef => $::operatingsystem ? {
        'CumulusLinux' => 'ifreload -a',
        default        => "ifdown ${interface}; ifup ${interface}",
      },
    default => $reload_command,
  }
  if $restart_all_nic == false and $::kernel == 'Linux' {
    exec { "network_restart_${name}":
      command     => $real_reload_command,
      path        => '/sbin',
      refreshonly => true,
    }
    $network_notify = "Exec[network_restart_${name}]"
  } else {
    $network_notify = $network::manage_config_file_notify
  }

  case $::osfamily {

    'Debian': {
      if $network::config_file_per_interface {
        if ! defined(File['/etc/network/interfaces.d']) {
          file { '/etc/network/interfaces.d':
            ensure => 'directory',
            mode   => '0755',
            owner  => 'root',
            group  => 'root',
          }
        }
        if $::operatingsystem == 'CumulusLinux' {
          file { "interface-${name}":
            ensure  => $ensure,
            path    => "/etc/network/interfaces.d/${name}",
            content => template($template),
            notify  => $network_notify,
          }
          if ! defined(File_line['config_file_per_interface']) {
            file_line { 'config_file_per_interface':
              ensure => $ensure,
              path   => '/etc/network/ifupdown2/ifupdown2.conf',
              line   => 'addon_scripts_support=1',
              match  => 'addon_scripts_suppor*',
              notify => $network_notify,
            }
          }
        } else {
          file { "interface-${name}":
            ensure  => $ensure,
            path    => "/etc/network/interfaces.d/${name}.cfg",
            content => template($template),
            notify  => $network_notify,
          }
          if ! defined(File_line['config_file_per_interface']) {
            file_line { 'config_file_per_interface':
              ensure => $ensure,
              path   => '/etc/network/interfaces',
              line   => 'source /etc/network/interfaces.d/*.cfg',
              notify => $network_notify,
            }
          }
        }
        File['/etc/network/interfaces.d']
        -> File["interface-${name}"]
      } else {
        if ! defined(Concat['/etc/network/interfaces']) {
          concat { '/etc/network/interfaces':
            mode   => '0644',
            owner  => 'root',
            group  => 'root',
            notify => $network_notify,
          }
        }

        concat::fragment { "interface-${name}":
          target  => '/etc/network/interfaces',
          content => template($template),
          order   => $manage_order,
        }

      }

      if ! defined(Network::Interface['lo']) {
        network::interface { 'lo':
          address      => '127.0.0.1',
          method       => 'loopback',
          manage_order => '05',
        }
      }
    }

    'RedHat': {
      file { "/etc/sysconfig/network-scripts/ifcfg-${name}":
        ensure  => $ensure,
        content => template($template),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => $network_notify,
      }
    }

    'Suse': {
      if $vlan {
        if !defined(Package['vlan']) {
          package { 'vlan':
            ensure => 'present',
          }
        }
        Package['vlan']
        -> File["/etc/sysconfig/network/ifcfg-${name}"]
      }
      if $bridge {
        if !defined(Package['bridge-utils']) {
          package { 'bridge-utils':
            ensure => 'present',
          }
        }
        Package['bridge-utils']
        -> File["/etc/sysconfig/network/ifcfg-${name}"]
      }

      file { "/etc/sysconfig/network/ifcfg-${name}":
        ensure  => $ensure,
        content => template($template),
        mode    => '0600',
        owner   => 'root',
        group   => 'root',
        notify  => $network_notify,
      }
    }

    'Solaris': {
      if $::operatingsystemrelease == '5.11' {
        if ! defined(Service['svc:/network/physical:nwam']) {
          service { 'svc:/network/physical:nwam':
            ensure => stopped,
            enable => false,
            before => [
              Service['svc:/network/physical:default'],
              Exec["create ipaddr ${title}"],
              File["hostname iface ${title}"],
            ],
          }
        }
      }
      case $::operatingsystemmajrelease {
        '11','5': {
          if $enable_dhcp {
            $create_ip_command = "ipadm create-addr -T dhcp ${title}/dhcp"
            $show_ip_command = "ipadm show-addr ${title}/dhcp"
          } else {
            $create_ip_command = "ipadm create-addr -T static -a ${ipaddress}/${netmask} ${title}/v4static"
            $show_ip_command = "ipadm show-addr ${title}/v4static"
          }
        }
        default: {
          $create_ip_command = 'true '
          $show_ip_command = 'true '
        }
      }
      exec { "create ipaddr ${title}":
        command => $create_ip_command,
        unless  => $show_ip_command,
        path    => '/bin:/sbin:/usr/sbin:/usr/bin:/usr/gnu/bin',
        tag     => 'solaris',
      }
      file { "hostname iface ${title}":
        ensure  => file,
        path    => "/etc/hostname.${title}",
        content => inline_template("<%= @ipaddress %> netmask <%= @netmask %>\n"),
        require => Exec["create ipaddr ${title}"],
        tag     => 'solaris',
      }
      host { $::fqdn:
        ensure       => present,
        ip           => $ipaddress,
        host_aliases => [$::hostname],
        require      => File["hostname iface ${title}"],
      }
      if ! defined(Service['svc:/network/physical:default']) {
        service { 'svc:/network/physical:default':
          ensure    => running,
          enable    => true,
          subscribe => [
            File["hostname iface ${title}"],
            Exec["create ipaddr ${title}"],
          ],
        }
      }
    }

    default: {
      alert("${::operatingsystem} not supported. No changes done here.")
    }

  }

}
