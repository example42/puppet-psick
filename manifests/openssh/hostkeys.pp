# @summary Manage ssh hostkeys sharing and known hosts on a node
#
# This class can collect the ssh keys of each host and manage the knownhosts files
#
# @example
#   include psick::openssh::hostkeys
class psick::openssh::hostkeys (

  Boolean $hostkey_export                = false,
  Boolean $hostkey_collect               = false,
  Array $hostkey_aliases                 = flatten([$facts['networking']['fqdn'], $facts['networking']['hostname'], $facts['networking']['ip']]),

  Boolean $knownhosts_manage             = false,
  Psick::Ensure $knownhosts_ensure       = 'present',
  Stdlib::Absolutepath $knownhosts_path  = '/etc/ssh/ssh_known_hosts',
  Optional[String] $knownhosts_source    = undef,
  Optional[String] $knownhosts_template  = undef,

  Boolean         $manage                = $psick::manage,
  Boolean         $auto_prereq           = $psick::auto_prereq,
  Boolean         $noop_manage           = $psick::noop_manage,
  Boolean         $noop_value            = $psick::noop_value,

) {
  # We declare resources only if $manage = true
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $hostkey_export {
      if getvar('facts.ssh.dsa.key') {
        @@sshkey { "${facts['networking']['fqdn']}_dsa":
          host_aliases => $hostkey_aliases,
          type         => dsa,
          key          => getvar('facts.ssh.dsa.key'),
        }
      }
      if getvar('facts.ssh.rsa.key') {
        @@sshkey { "${facts['networking']['fqdn']}_rsa":
          host_aliases => $hostkey_aliases,
          type         => rsa,
          key          => getvar('facts.ssh.rsa.key'),
        }
      }
      if getvar('facts.ssh.ecdsa.key') {
        @@sshkey { "${facts['networking']['fqdn']}_ecdsa":
          host_aliases => $hostkey_aliases,
          type         => 'ecdsa-sha2-nistp256',
          key          => getvar('facts.ssh.ecdsa.key'),
        }
      }
    }

    if $hostkey_collect {
      Sshkey <<| |>> {
        ensure => present,
      }
    }

    if $knownhosts_manage {
      file { $knownhosts_path:
        ensure  => $knownhosts_ensure,
        source  => $knownhosts_source,
        content => psick::template($knownhosts_template),
      }
    }
  }
}
