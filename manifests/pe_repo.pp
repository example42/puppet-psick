# This class manages the /etc/yum.repos.d/pe_repo.repo file
#
# @param ensure If to add or remove the pe_repo.repo file
#
class psick::pe_repo (
  Enum['present','absent'] $ensure = 'present',
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    file { '/etc/yum.repos.d/pe_repo.repo':
      ensure => $ensure,
      source => 'puppet:///modules/psick/pe_repo/pe_repo.repo',
    }
  }
}
