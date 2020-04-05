# Configures proxy settings on different package managers
#
# @param ensure If to add or remove the proxy configuration
# @param configure_gem Configure proxy for gem
# @param configure_puppet_gem Configure proxy for puppet gem
# @param configure_pip Configure proxy for pip
# @param configure_system Export proxy global vars on startup script
# @param configure_repo Configure proxy on package repos
# @param proxy_server Hash with the proxy server data. Default is based on
#   psick::proxy_server
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
class psick::proxy (
  Enum['present','absent'] $ensure = 'present',
  Boolean $configure_gem           = true,
  Boolean $configure_puppet_gem    = true,
  Boolean $configure_pip           = true,
  Boolean $configure_system        = true,
  Boolean $configure_repo          = true,
  Optional[Hash] $proxy_server     = $::psick::servers['proxy'],

  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if !empty($proxy_server) {
      if !empty($proxy_server['user']) and !empty($proxy_server['password']) {
        $proxy_credentials = "${proxy_server['user']}:${proxy_server['password']}@"
      } else {
        $proxy_credentials = ''
      }
      $proxy_url = "${proxy_server['scheme']}://${proxy_credentials}${proxy_server['host']}:${proxy_server['port']}"
    } else {
      $proxy_url = ''
    }

    if $configure_gem and !empty($proxy_server) {
      ini_setting { 'proxy_gem':
        ensure            => $ensure,
        path              => '/etc/gemrc',
        key_val_separator => ': ',
        setting           => 'gem',
        value             => "-p ${proxy_url}",
      }
    }
    if $configure_puppet_gem and !empty($proxy_server) {
      file { '/opt/puppetlabs/puppet/etc':
        ensure => directory,
      }
      ini_setting { 'proxy_puppet_gem':
        ensure            => $ensure,
        path              => '/opt/puppetlabs/puppet/etc/gemrc',
        key_val_separator => ': ',
        setting           => 'gem',
        value             => "-p ${proxy_url}",
      }
    }
    if $configure_pip and !empty($proxy_server) {
      ini_setting { 'proxy_pip':
        ensure            => $ensure,
        path              => '/etc/pip.conf',
        key_val_separator => '=',
        section           => 'global',
        setting           => 'proxy',
        value             => "${proxy_server['host']}:${proxy_server['port']}",
      }
    }
    if $configure_system and $proxy_server != {} {
      psick::profile::script { 'proxy':
        ensure  => $ensure,
        content => epp('psick/proxy/proxy.sh.epp'),
        # Template has to be evaluated here: it uses local scope vars
      }
    }
    if $configure_repo and !empty($proxy_server) {
      case $::osfamily {
        'RedHat': {
          ini_setting { 'proxy_yum':
            ensure            => $ensure,
            path              => '/etc/yum.conf',
            key_val_separator => '=',
            section           => 'main',
            setting           => 'proxy',
            value             => "${proxy_server[scheme]}://${proxy_server['host']}:${proxy_server['port']}",
          }
          if has_key($proxy_server,'user') and has_key($proxy_server,'password') {
            ini_setting { 'proxy_user_yum':
              ensure            => $ensure,
              path              => '/etc/yum.conf',
              key_val_separator => '=',
              section           => 'main',
              setting           => 'proxy_username',
              value             => $proxy_server['user'],
            }
            ini_setting { 'proxy_password_yum':
              ensure            => $ensure,
              path              => '/etc/yum.conf',
              key_val_separator => '=',
              section           => 'main',
              setting           => 'proxy_password',
              value             => $proxy_server['password'],
            }
          }
        }
        'Debian': {
          file { '/etc/apt/apt.conf.d/80proxy':
            ensure  => $ensure,
            content => epp('psick/proxy/proxy.apt.epp'),
          }
        }
        default: {
          notify { 'Proxy':
            message => "No proxy configuration available for ${::osfamily} repos",
          }
        }
      }
    }
  }
}
