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
  Optional[String]  $r10k_remote_repo     = undef,
  Optional[String]  $git_remote_repo      = undef,
  Boolean           $manage_puppetdb_repo = true,
  Boolean           $enable_puppetdb      = true,
  String            $dns_alt_names        = "puppet, puppet.${::domain}",
  Boolean           $remove_global_hiera_yaml = false,
){
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
  # step 1 generate ca
  exec { '/opt/puppetlabs/puppet/bin/puppet cert list --all --allow-dns-alt-names':
    creates   => '/etc/puppetlabs/puppet/ssl/ca/ca_key.pem',
    logoutput => true,
  }
  # step 2: generate host certificate
  exec { "/opt/puppetlabs/puppet/bin/puppet cert generate ${::facts['networking']['fqdn']}":
    creates   => "/etc/puppetlabs/puppet/ssl/certs/${::facts['networking']['fqdn']}.pem",
    logoutput => true,
  }

  if $r10k_remote_repo {
    class { 'r10k':
      remote   => $r10k_remote_repo,
      provider => 'puppet_gem',
    }
    class {'r10k::webhook::config':
      enable_ssl      => false,
      use_mcollective => false,
      require         => Class['r10k'],
    }
    class {'r10k::webhook':
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
      before                  => Service['puppetserver'],
    }
  }

  if $remove_global_hiera_yaml {
    file { '/etc/puppetlabs/puppet/hiera.yaml':
      ensure => absent,
    }
  }
}
