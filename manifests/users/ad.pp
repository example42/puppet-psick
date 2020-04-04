# Class psick::users::ad
# This class uses trlinkin/domain_membership for domain join on Windows
#
# @example Hiera configuration example
#   psick::users::ad::domain: 'my.ads.domain'
#   psick::users::ad::username: 'Domain Administrator'
#   psick::users::ad::password: 'secret'
#   psick::users::ad::create_machine_account: true
#   psick::users::ad::machine_ou: '$null'
#
class psick::users::ad (
  String $domain,
  String $username,
  String $password,
  String $machine_ou,
  Boolean $create_machine_account = true,

  Boolean $manage      = $::psick::manage,
  Boolean $noop_manage = $::psick::noop_manage,
  Boolean $noop_value  = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $::kernel == 'Linux' {
      class { '::sssd':
        domains => $domain,
      }
    }
    if $::kernel == 'Windows' {
      $join_options = $create_machine_account ? {
        true  => '3',
        false => '1',
      }

      class { '::domain_membership':
        domain       => $domain,
        username     => $username,
        password     => $password,
        resetpw      => false,
        machine_ou   => $machine_ou,
        join_options => $join_options,
      }
    }
  }
}
