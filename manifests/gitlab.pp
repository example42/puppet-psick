# This class installs GitLab Community Edition using Tiny Puppet
#
# @param ensure Define if to install or remove gitlab, and eventually the
#               package version to use
# @param template Path (as used in template()) of the Erb template to use to
#                 manage GitLab configuration file.
# @param options_hash An hash of options to eventually use in the provided template
# @param manage_installation Set to true to atually install GitLab. Default,
#                            false, just manages symlink in /etc/ssh/auth_keys
# @param use_https Define if you want gitlab services to use ssl.
# @param server_name The name to use for the GitLab website. Default: $::fqdn,
#                    If you set a name different from the local machine fqdn,
#                    provide custom cert files via *_file_source params
# @param ca_file_source Puppet source for the ca certificate. By default Puppet CA is
#                 used (valid if server_name is not customised)
# @param cert_file_source Puppet source for the https server certificate. By default
#                   local Puppet cert is used (valid if server_name is not customised)
# @param key_file_source Puppet source for the https server key. By default
#                   local Puppet key is used (valid if server_name is not customised)
# @param users An hash used to create psick::gitlab::user resources
# @param groups An hash used to create psick::gitlab::group resources
# @param projects An hash used to create psick::gitlab::project resources
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed. Default value is taken from main psick class.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class). Default from psick class.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#                   Default from psick class.
#
class psick::gitlab (
  String $ensure                       = 'present',

  Variant[Undef,String] $template      = undef,
  Hash $options_hash                   = { },

  Boolean $manage_installation         = true,
  Boolean $manage_inline_configuration = false,

  Boolean $use_https                   = true,
  String $server_name                  = $::fqdn,
  String $ca_file_source               = 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem',
  String $key_file_source              = "file:///etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
  String $cert_file_source             = "file:///etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",

  Hash $tp_install_options             = { },
  Hash $users                          = { },
  Hash $groups                         = { },
  Hash $projects                       = { },

  Boolean $manage                      = $::psick::manage,
  Boolean $noop_manage                 = $::psick::noop_manage,
  Boolean $noop_value                  = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $external_url = $use_https ? {
      true  => "https://${server_name}",
      false => "http://${server_name}",
    }
    $options_default = $use_https ? {
      true  => {
        "nginx['ssl_certificate']"     => "/etc/gitlab/ssl/${server_name}.crt",
        "nginx['ssl_certificate_key']" => "/etc/gitlab/ssl/${server_name}.key",
      },
      false => {},
    }
    $options = $options_default + $options_hash

    if $manage_installation {
      tp::install { 'gitlab-ce' :
        ensure      => $ensure,
        auto_prereq => true,
        *           => $tp_install_options,
      }
    }

    if $template {
      ::tp::conf { 'gitlab-ce':
        ensure  => $ensure,
        content => template($template),
        notify  => Exec['gitlab-ctl reconfigure'],
      }
    } else {
      if $manage_inline_configuration {
        file { '/etc/gitlab/gitlab.rb':
          ensure => present,
        }
        file_line { 'gitlab external_url':
          path    => '/etc/gitlab/gitlab.rb',
          line    => "external_url '${external_url}'",
          match   => '^external_url',
          notify  => Exec['gitlab-ctl reconfigure'],
          require => File['/etc/gitlab/gitlab.rb'],
        }
        $options.each | $k,$v | {
          $real_value = $v ? {
            String  => "'${v}'",
            default => $v
          }
          ini_setting { "gitlab ${k}":
            ensure  => present,
            path    => '/etc/gitlab/gitlab.rb',
            setting => $k,
            value   => $real_value,
            notify  => Exec['gitlab-ctl reconfigure'],
          }
        }
      }
    }

    exec { 'gitlab-ctl reconfigure':
      refreshonly => true,
      timeout     => '600',
      subscribe   => Package['gitlab-ce'],
    }

    if $use_https {
      file { '/etc/gitlab/ssl':
        ensure  => directory, # tp::ensure2dir($ensure),
        require => Package['gitlab-ce'],
      }
      file { '/etc/gitlab/trusted-certs':
        ensure  => directory, # tp::ensure2dir($ensure),
        require => Package['gitlab-ce'],
      }
      file { "/etc/gitlab/ssl/${server_name}.crt":
        ensure => $ensure,
        source => $cert_file_source,
        notify => Exec['gitlab-ctl reconfigure'],
      }
      file { "/etc/gitlab/ssl/${server_name}.key":
        ensure => $ensure,
        source => $key_file_source,
        mode   => '0400',
        notify => Exec['gitlab-ctl reconfigure'],
      }
      file { '/etc/gitlab/trusted-certs/ca_bundle.crt':
        ensure => $ensure,
        source => $ca_file_source,
        notify => Exec['gitlab-ctl reconfigure'],
      }
    }

    # Create GitLab resources, if defined
    if $groups != {} {
      $groups.each |$k,$v| {
        psick::gitlab::group { $k:
          * => $v,
        }
      }
    }
    if $users != {} {
      $users.each |$k,$v| {
        psick::gitlab::user { $k:
          * => $v,
        }
      }
    }
    if $projects != {} {
      $projects.each |$k,$v| {
        psick::gitlab::project { $k:
          * => $v,
        }
      }
    }

    # Add tp test if cli enabled
    if any2bool($::psick::tp['cli_enable']) {
      tp::test { 'gitlab-ce':
        content => 'gitlab-ctl status',
      }
    }
  }
}
