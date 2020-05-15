# This class installs and configures PE client tools
#
class psick::puppet::pe_client_tools (
  Enum['present','absent'] $ensure = present,
  Boolean $manage_pe_repo          = true,
  Optional[String] $token          = undef,
  String $token_user               = 'root',
  String $puppet_server            = $servername,
  String $puppetdb_server          = $servername,
  String $console_server           = $servername,
  Optional[String] $package_url    = undef,
  Hash $orchestrator_options       = {},
  Hash $puppet_access_options      = {},
  Hash $puppet_code_options        = {},
  Hash $puppetdb_options           = {},
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $manage_pe_repo {
      case $::osfamily {
        'RedHat': {
          yumrepo { 'pe_repo':
            ensure    => $ensure,
            baseurl   => "https://${puppet_server}:8140/packages/current/el-${::operatingsystemmajrelease}-${::architecture}",
            descr     => 'Puppet Labs PE Packages \$releasever - \$basearch',
            enabled   => '1',
            gpgcheck  => '1',
            gpgkey    => "https://${puppet_server}:8140/packages/GPG-KEY-puppet-2025-04-06\n       https://${puppet_server}:8140/packages/GPG-KEY-puppet",
            sslverify => false,
          }
        }
        'Debian': {
          $debian_version = $::operatingsystemmajrelease
          file { '/apt/sources.list.d/pe_repo.repo':
            ensure  => $ensure,
            content => "deb https://${puppet_server}:8140/packages/latest/debian-${debian_version}-${::os['architecture']} ${::os['distro']['codename']} puppet6",
            before  => Package['pe-client-tools'],
          }
        }
        default: {}
      }
    }
    package { 'pe-client-tools':
      ensure => $ensure,
    }

    if $token {
      $puppetlabs_dir = $token_user ? {
        'root'  => '/root/.puppetlabs/',
        default => "/home/${token_user}/.puppetlabs/",
      }
      psick::tools::create_dir { "pe-client-tools token dir ${puppetlabs_dir}":
        path   => $puppetlabs_dir,
        owner  => $token_user,
        before => File["${puppetlabs_dir}/token"],
      }
      file { "${puppetlabs_dir}/token":
        ensure  => $ensure,
        content => $token,
        owner   => $token_user,
      }
    }

    $orchestrator_defaults = {
      'options' => {
        'service-url' => "https://${puppet_server}:8143",
      }
    }
    file { '/etc/puppetlabs/client-tools/orchestrator.conf':
      ensure  => $ensure,
      content => to_json($orchestrator_defaults + $orchestrator_options),
      require => Package['pe-client-tools'],
    }

    $puppet_access_defaults = {
      'service-url' => "https://${console_server}:8433/rbac-api",
    }
    file { '/etc/puppetlabs/client-tools/puppet-access.conf':
      ensure  => $ensure,
      content => to_json($puppet_access_defaults + $puppet_access_options),
      require => Package['pe-client-tools'],
    }

    $puppet_code_defaults = {
      'service-url' => "https://${puppet_server}:8170/code-manager",
    }
    file { '/etc/puppetlabs/client-tools/puppet-code.conf':
      ensure  => $ensure,
      content => to_json($puppet_code_defaults + $puppet_code_options),
      require => Package['pe-client-tools'],
    }

    $puppetdb_defaults = {
      'puppetdb' => {
        'server-urls' => "https://${puppetdb_server}:8081",
        'cacert'      => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
      }
    }
    file { '/etc/puppetlabs/client-tools/puppetdb.conf':
      ensure  => $ensure,
      content => to_json($puppetdb_defaults + $puppetdb_options),
      require => Package['pe-client-tools'],
    }

  }
}
