function psick::ensure2file (
  Psick::Ensure $ensure = 'present',
) {

  $output = $ensure ? {
    'absent'  => 'absent',
    false     => 'absent',
    default   => 'present',
  }

}
