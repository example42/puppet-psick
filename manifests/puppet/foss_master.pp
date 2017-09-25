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
  Boolean           $manage_puppetdb_repo = true,
  Boolean           $enable_puppetdb      = true,
  String            $dns_alt_names        = "puppet, puppet.${::domain}",
){
  if versioncmp('5', $facts['puppetversion']) > 0 {
    $postgresversion = '9.4'
  } else {
    $postgresversion = '9.6'
  }

  contain ::psick::git
  contain puppetserver
  # Workflow: create puppetserver ssl ca and certificates
  ini_setting { 'puppet master dns alt names':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'dns_alt_names',
    value   => $dns_alt_name_entries,
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
      require  => Class['psick::git'],
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
}

