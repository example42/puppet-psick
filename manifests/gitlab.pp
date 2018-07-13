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
#
class psick::gitlab (
  String                $ensure      = 'present',

  Variant[Undef,String] $template    = undef,
  Hash $options_hash                 = { },

  Boolean $manage_installation       = true,

  Boolean $use_https                 = true,
  String $server_name                = $::fqdn,
  String $ca_file_source             = 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem',
  String $key_file_source            = "file:///etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
  String $cert_file_source           = "file:///etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",

  Hash                  $users       = { },
  Hash                  $groups      = { },
  Hash                  $projects    = { },
) {

  if $manage_installation {
    $options_default = {
      external_url => $use_https ? {
        true  => "https://${server_name}",
        false => "http://${server_name}",
      },
      "nginx['ssl_certificate']" => "/etc/gitlab/ssl/${server_name}.crt",
      "nginx['ssl_certificate_key']" => "/etc/gitlab/ssl/${server_name}.key",
    }
    $options = $options_default + $options_hash
    ::tp::install { 'gitlab-ce' :
      ensure => $ensure,
    }

    if $template {
      ::tp::conf { 'gitlab-ce':
        ensure  => $ensure,
        content => template($template), 
        notify  => Exec['gitlab-ctl reconfigure'],
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
