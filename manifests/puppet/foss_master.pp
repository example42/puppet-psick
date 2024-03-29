# Class psick::puppet::foss_master
#
# this class bootstraps a Puppet Open Source master
#
# @param r10k_remote_repo (default: '') specify the git URL to your control repo
# @param manage_puppetdb_repo (default: true)
# @param enable_puppetdb (default true)
#
# example usage:
#   contain psick::puppet::foss_master
#
#   class { 'psick::puppet::foss_master':
#     r10k_repmote_repo = 'https://github.com/example42/psick.git'
#   }
#
# TODO:
#
# - make all default repos optional
# - ensure DNS alt names are possible for puppet server
# - separate puppetdb host
# - separate postgresql host
# - allow multi master setup
# - allow multiple control-repos
#
class psick::puppet::foss_master (
  Optional[String]  $r10k_remote_repo         = undef,
  Optional[String]  $git_remote_repo          = undef,
  Boolean           $manage_puppetdb_repo     = true,
  Boolean           $enable_puppetdb_sslsetup = false,
  Boolean           $enable_puppetdb          = true,
  String            $dns_alt_names            = "puppet,puppet.${facts['networking']['domain']}",
  Boolean           $remove_global_hiera_yaml = false,
  Boolean $manage                  = $psick::manage,
  Boolean $noop_manage             = $psick::noop_manage,
  Boolean $noop_value              = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if versioncmp('5', $facts['puppetversion']) > 0 {
      $postgresversion = '9.4'
    } else {
      $postgresversion = '9.6'
    }

    contain puppetserver
    # Workflow: create puppetserver ssl ca and certificates
    ini_setting { 'puppet master dns alt names':
      ensure  => present,
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'master',
      setting => 'dns_alt_names',
      value   => $dns_alt_names,
    }

    case $facts['puppetversion'] {
      /^(3|4|5)/: {
        $cert_list_command = '/opt/puppetlabs/puppet/bin/puppet cert list --all --allow-dns-alt-names'
        $cert_generate_command = "/opt/puppetlabs/puppet/bin/puppet cert generate ${facts['networking']['fqdn']}"
      }
      default: {
        $cert_list_command = undef
        $cert_generate_command =  '/opt/puppetlabs/bin/puppetserver ca setup'
      }
    }

    if $cert_list_command {
      exec { $cert_list_command:
        creates   => '/etc/puppetlabs/puppet/ssl/ca/ca_key.pem',
        logoutput => true,
        require   => [Package['puppetserver'], Ini_setting['puppet master dns alt names']],
      }
    }
    if $cert_generate_command {
      exec { $cert_generate_command:
        creates   => "/etc/puppetlabs/puppet/ssl/certs/${facts['networking']['fqdn']}.pem",
        logoutput => true,
        require   => [Package['puppetserver'], Ini_setting['puppet master dns alt names']],
      }
    }

    if $r10k_remote_repo {
      class { 'r10k':
        remote   => $r10k_remote_repo,
        provider => 'puppet_gem',
      }
      class { 'r10k::webhook::config':
        enable_ssl      => false,
        use_mcollective => false,
        require         => Class['r10k'],
      }
      class { 'r10k::webhook':
        use_mcollective => false,
        user            => 'root',
        group           => '0',
        require         => Class['r10k::webhook::config'],
      }
    }

    if $git_remote_repo {
      exec { 'remove default controlrepo':
        command => 'mv /etc/puppetlabs/code/environments/production /etc/puppetlabs/code/environments/production.default',
        creates => '/etc/puppetlabs/code/environments/production.default',
        before  => Tp::Dir['puppet::control-repo'],
      }
      tp::dir { 'puppet::control-repo':
        path               => '/etc/puppetlabs/code/environments/production',
        vcsrepo            => 'git',
        source             => $git_remote_repo,
        config_dir_notify  => false,
        config_dir_require => false,
        notify             => Exec['r10k puppetfile install'],
      }
      exec { 'r10k puppetfile install':
        command     => 'r10k puppetfile install',
        cwd         => '/etc/puppetlabs/code/environments/production',
        path        => '/opt/puppetlabs/puppet/bin:/usr/bin',
        refreshonly => true,
        # require     => Package['r10k'],
      }
    }

    if $enable_puppetdb {
      class { 'puppetdb':
        manage_firewall     => false,
        manage_package_repo => $manage_puppetdb_repo,
        ssl_protocols       => 'TLSv1.2',
        postgres_version    => $postgresversion,
      }
      class { 'puppetdb::master::config':
        manage_report_processor => true,
        enable_reports          => true,
        restart_puppet          => false,
        require                 => Service['puppetserver'],
      }
      if $enable_puppetdb_sslsetup {
        exec { 'puppetdb ssl-setup':
          command => '/opt/puppetlabs/bin/puppetdb ssl-setup',
          creates => '/etc/puppetlabs/puppetdb/ssl/private.pem',
          require => Package['puppetdb'],
          notify  => Service['puppetdb'],
        }
      }
    }

    if $remove_global_hiera_yaml {
      file { '/etc/puppetlabs/puppet/hiera.yaml':
        ensure => absent,
      }
    }
  }
}
