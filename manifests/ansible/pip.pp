# @summary Install ansible using pip
#
class psick::ansible::pip (

  Variant[Boolean,String] $ensure           = pick($::psick::ansible::ensure, 'present'),

) {

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
