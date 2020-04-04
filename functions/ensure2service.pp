function psick::ensure2service (
  Psick::Ensure $ensure = 'present',
  Enum['ensure','enable'] $param  = 'ensure',
) {

  case $param {
    'ensure': {
      $output = $ensure ? {
        'absent'  => 'stopped',
        false     => 'stopped',
        default   => 'running',
      }
    }
    'enable': {
      $output = $ensure ? {
        'absent'  => false,
        false     => false,
        default   => true,
      }
    }
    default: {}
  }
}
