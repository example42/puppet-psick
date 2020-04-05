# @class psick::puppetserver
#
class psick::puppetserver (

  Variant[Boolean,String]       $ensure = present,
  Enum['tp_profile', 'puppetserver'] $module = 'tp_profile',

  Optional[String]  $r10k_remote_repo     = undef,
  Optional[String]  $r10k_template        = 'psick/puppet/r10k/r10k.yaml.erb',
  Hash $r10k_options                      = {},
  Boolean $r10k_configure_webhook         = true,
  Boolean $r10k_autodeploy                = true,
  String $r10k_postrun_command            = '/usr/local/bin/generate_types.sh',
  String[1] $r10k_postrun_source          = 'puppet:///modules/psick/puppet/generate_types.sh',

  Optional[String]  $git_remote_repo      = undef,
  String            $dns_alt_names        = "puppet,puppet.${::domain}",
  Boolean           $remove_global_hiera_yaml = false,

  Boolean           $manage               = $::psick::manage,
  Boolean           $noop_manage          = $::psick::noop_manage,
  Boolean           $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    # Installation management
    case $module {
      'tp_profile': {
        contain tp_profile::puppetserver
        $puppetserver_class = 'tp_profile::puppetserver'
      }
      'puppetserver': {
        contain ::puppetserver
        $puppetserver_class = 'puppetserver'
      }
      default: {}
    }

    ini_setting { 'puppet master dns alt names':
      ensure  => present,
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'master',
      setting => 'dns_alt_names',
      value   => $dns_alt_names,
      before  => Service['puppetserver'],
    }

    case $facts['puppetversion'] {
      /^(3|4|5)/: {
        # step 1 generate ca
        exec { '/opt/puppetlabs/puppet/bin/puppet cert list --all --allow-dns-alt-names':
          creates   => '/etc/puppetlabs/puppet/ssl/ca/ca_key.pem',
          logoutput => true,
          require   => [ Package['puppetserver'], Ini_setting['puppet master dns alt names'] ],
        }
        # step 2: generate host certificate
        exec { "/opt/puppetlabs/puppet/bin/puppet cert generate ${::facts['networking']['fqdn']}":
          creates   => "/etc/puppetlabs/puppet/ssl/certs/${::facts['networking']['fqdn']}.pem",
          logoutput => true,
          require   => [ Package['puppetserver'], Ini_setting['puppet master dns alt names'] ],
        }
      }
      /^(6)/: {
        # step 1 generate ca
        exec { "/opt/puppetlabs/bin/puppetserver ca setup --subject-alt-names ${dns_alt_names} --certname ${::facts['networking']['fqdn']}":
          creates   => '/etc/puppetlabs/puppet/ssl/ca/ca_key.pem',
          logoutput => true,
          require   => [ Package['puppetserver'], Ini_setting['puppet master dns alt names'] ],
        }
      }
      default: { }
    }

    if $r10k_remote_repo or $r10k_options {
      # r10k gem is expected to be already installed
      # for example by psick::puppet::gems
      # He we configure just r10k.yaml and eventually the webhook
      # using puppetlabs-r10k module
      $r10k_sources  = {
        'puppet' => {
          'remote'  => $r10k_remote_repo,
          'basedir' => '/etc/puppetlabs/code/environments',
        }
      }
      $r10k_default_options = {
        postrun         => [$r10k_postrun_command],
        cachedir        => "${facts['puppet_vardir']}/r10k",
        sources         => $r10k_sources,
        source_keys     => keys($r10k_sources),
        deploy_settings => {},
        git_settings    => {},
        forge_settings  => {},
      }
      $r10k_real_options = $r10k_default_options + $r10k_options
      if $r10k_template {
        file { '/etc/puppetlabs/r10k':
          ensure => directory,
        }
        file { '/etc/puppetlabs/r10k/r10k.yaml':
          ensure  => present,
          content => template($r10k_template),
        }
        file { $r10k_postrun_command:
          ensure => file,
          mode   => '0755',
          source => $r10k_postrun_source,
        }
      }
      if $r10k_autodeploy and $r10k_template {
        exec { 'r10k deploy environment':
          path        => '/opt/puppetlabs/puppet/bin',
          refreshonly => true,
          subscribe   => File['/etc/puppetlabs/r10k/r10k.yaml'],
        }
      }
      if $r10k_configure_webhook {
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

    if $remove_global_hiera_yaml {
      file { '/etc/puppetlabs/puppet/hiera.yaml':
        ensure => absent,
      }
    }
  }
}
