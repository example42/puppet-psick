function psick::ensure2dir (
  Psick::Ensure $ensure = 'present',
) {

  $output = $ensure ? {
    'absent'  => absent,
    false     => absent,
    default   => 'directory',
  }

}
