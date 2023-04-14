# This class installs and configures PE client tools
#
class psick::puppet::pe_client_tools (
  Enum['present','absent'] $ensure = present,

  String $download_base_url        = 'https://pm.puppetlabs.com/pe-client-tools',
  Optional[String] $package_url    = undef,
  Optional[String] $package_name   = undef,

  String $pe_version               = '2021.5.0',
  String $repo_path                = '',
  String $package_suffix           = '',
  String $package_separator        = '-',
  String $package_download_dir     = '/var/tmp',

  Optional[String] $token          = undef,
  String $token_user               = 'root',
  String $puppet_server            = $servername,
  String $puppetdb_server          = $servername,
  String $console_server           = $servername,

  Hash $orchestrator_options       = {},
  Hash $puppet_access_options      = {},
  Hash $puppet_code_options        = {},
  Hash $puppetdb_options           = {},
  Boolean $manage                  = $psick::manage,
  Boolean $noop_manage             = $psick::noop_manage,
  Boolean $noop_value              = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $pe_short_version = regsubst($pe_version,'^20','')

    # Madness will be
    $pe_patch = $pe_short_version ? {
      '21.5.0' => $::kernel ? {
        'windows' => '',
        default   => '-1',
      },
      default  => '',
    }

    $full_package_url = $package_url ? {
      undef   => "${download_base_url}/${pe_version}/${pe_short_version}/repos/${repo_path}/pe-client-tools${package_separator}${pe_short_version}${pe_patch}${package_suffix}", # lint:ignore:140chars
      default => $package_url,
    }
    $full_package_name = $package_name ? {
      undef   => "pe-client-tools${package_separator}${pe_short_version}${pe_patch}${package_suffix}", # lint:ignore:140chars
      default => $package_name,
    }

    $package_provider = $facts['os']['family'] ? {
      'RedHat'  => 'rpm',
      'Debian'  => 'dpkg',
      'Suse'    => 'rpm',
      'Darwin'  => 'pkgdmg',
      'windows' => 'windows',
      default   => undef,
    }

    psick::netinstall { 'pe-client-tools':
      url             => $full_package_url,
      destination_dir => $package_download_dir,
      work_dir        => $package_download_dir,
      extract_command => false,
    }
    -> package { 'pe-client-tools':
      ensure   => $ensure,
      provider => $package_provider,
      source   => "${package_download_dir}/${full_package_name}",
    }

    if $token {
      $puppetlabs_dir = $token_user ? {
        'root'  => '/root/.puppetlabs/',
        default => $facts[os][family] ? {
          'Darwin'  => "/Users/${token_user}/.puppetlabs/",
          'windows' => "C:/Users/${token_user}/.puppetlabs/",
          default   => "/home/${token_user}/.puppetlabs/",
        }
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
      },
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
      },
    }
    file { '/etc/puppetlabs/client-tools/puppetdb.conf':
      ensure  => $ensure,
      content => to_json($puppetdb_defaults + $puppetdb_options),
      require => Package['pe-client-tools'],
    }
  }
}
