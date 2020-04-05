# This class automatically includes ::psick::hardware::hp on HP servers
#
class psick::hardware (
  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $::manufacturer == 'HP' { contain ::psick::hardware::hp }
  }
}
