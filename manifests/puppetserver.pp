# @class puppetserver
#
class psick::puppetserver (

  Variant[Boolean,String]    $ensure = present,
  Enum['psick']              $module = 'psick',

  Optional[String]  $r10k_remote_repo     = undef,
  Optional[String]  $git_remote_repo      = undef,
  String            $dns_alt_names        = "puppet, puppet.${::domain}",
  Boolean           $remove_global_hiera_yaml = false,  
) {

  # Installation management
  case $module {
    'psick': {
      contain ::psick::puppetserver::tp
    }
    default: {
      contain ::puppetserver
    }
  }

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
      command     => 'mv /etc/puppetlabs/code/environments/production /etc/puppetlabs/code/environments/production.default',
      creates     => '/etc/puppetlabs/code/environments/production.default',
      before      => Tp::Dir['puppet::control-repo'],
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

  if $remove_global_hiera_yaml {
    file { '/etc/puppetlabs/puppet/hiera.yaml':
      ensure => absent,
    }
  }
}
