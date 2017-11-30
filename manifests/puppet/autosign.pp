# class psick::puppet::autosign
#
class psick::puppet::autosign (
  Enum['on', 'off', 'policy_based'] $autosign         = 'policy_based',
  Optional[String]                  $autosign_match   = undef,
  Optional[Array]                   $policy_based_psk = ['123456'],
){
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }
  Ini_setting {
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
  }
  case $autosign {
    'off', default: {
      ini_setting { 'puppet_server_autosign_off':
        ensure  => absent,
      }
    }
    'on': {
      if $autosign_match {
        ini_setting { 'puppet_server_autosign_on':
          ensure => present,
          value  => '/etc/puppetlabs/puppet/autosign.conf',
        }
        file { '/etc/puppetlabs/puppet/autosign.conf':
          ensure  => file,
          content => $autosign_match,
        }
      } else {
        ini_setting { 'puppet_server_autosign_on':
          ensure => present,
          value  => true,
        }
      }
    }
    'policy_based': {
      ini_setting { 'puppet_server_autosign_policy':
        ensure => present,
        value  => '/etc/puppetlabs/puppet/autosign.sh',
      }
      file { '/etc/puppetlabs/puppet/autosign.sh':
        ensure => file,
        mode   => '0755',
        source => 'puppet:///modules/psick/puppet/autosign.sh',
      }
      if $policy_based_psk {
        file { '/etc/puppetlabs/puppet/autosign_psk':
          ensure  => file,
          mode    => '0444',
          content => epp('psick/puppet/autosign_psk.epp'),
        }
      }
    }
  }
}
