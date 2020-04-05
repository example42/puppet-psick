# @summary Install ansible using pip
#
class psick::ansible::pip (

  Variant[Boolean,String] $ensure        = pick($::psick::ansible::ensure, 'present'),

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    include ::ansible

    if $::psick::ansible::auto_prereq {
      include ::psick::python::pip
      Class['psick::python::pip'] -> Package['ansible']
    }

    package { 'ansible':
      ensure   => $ensure,
      provider => 'pip',
    }
  }
}
