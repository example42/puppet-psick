# Class psick::puppet::install_ca adds Puppet's CA to the list
# of CAs trusted by the system. Useful for any application that
# uses a CA PKI infrastructure.
class psick::puppet::install_ca (
  Optional[String] $ca_ssl_dir        = undef,
  Optional[String] $ca_setup_command  = undef,
  Optional[String] $ca_update_command = undef,
  Optional[String] $ca_package        = undef,
  Boolean          $auto_prereq       = $::psick::auto_prereq,
  Boolean          $no_noop           = false,
  Boolean          $manage            = $::psick::manage,
) {

  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::puppet::install_ca')
      noop(false)
    }

    if $ca_package {
      $package_notify = $ca_setup_command ? {
        undef   => undef,
        default => Exec['setup ca certs'],
      }
      package { $ca_package:
        notify => $package_notify,
      }
    }
    if $ca_setup_command {
      exec { 'setup ca certs':
        refreshonly => true,
        command     => $ca_setup_command,
      }
    }
    if $ca_ssl_dir {
      file { "${ca_ssl_dir}/Puppet_CA.crt":
        ensure => present,
        source => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem',
        notify => Exec['update ca certs'],
      }
    }
    if $ca_update_command {
      exec { 'update ca certs':
        refreshonly => true,
        command     => $ca_update_command,
      }
    }
  }
}
