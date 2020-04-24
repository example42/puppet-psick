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
      file { '/etc/yum.repos.d/pe_repo.repo':
        ensure => $ensure,
        source => "https://${puppet_server}:8140/packages/current/el-${operatingsystemmajrelease}-x86_64.repo",
        before => Package['pe-client-tools'],
      }
    }
    package { 'pe-client-tools':
      ensure => $ensure,
    }

    if $token {
      $puppetlabs_dir = $user ? {
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
        'service_url' => "https://${puppet_server}:8143",
      }
    }
    file { '/etc/puppetlabs/client-tools/orchestrator.conf':
      ensure  => $ensure,
      content => to_json($orchestrator_defaults + $orchestrator_options),
    }

    $puppet_access_defaults = {
      'service_url' => "https://${console_server}:8433/rbac-api",
    }
    file { '/etc/puppetlabs/client-tools/puppet-access.conf':
      ensure  => $ensure,
      content => to_json($puppet_access_defaults + $puppet_access_options),
    }

    $puppet_code_defaults = {
      'service_url' => "https://${puppet_server}:8170/code-manager",
    }
    file { '/etc/puppetlabs/client-tools/puppet-code.conf':
      ensure  => $ensure,
      content => to_json($puppet_code_defaults + $puppet_code_options),
    }

    $puppetdb_defaults = {
      'puppetdb' => {
        'server_urls' => "https://${puppetdb_server}:8081",
        'cacert'      => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
      }
    }
    file { '/etc/puppetlabs/client-tools/puppetdb.conf':
      ensure  => $ensure,
      content => to_json($puppetdb_defaults + $puppetdb_options),
    }

  }
}
