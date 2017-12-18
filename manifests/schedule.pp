# This class defines Puppet schedules which might be used in
# other parts of the code.
#
psick::schedule (
  Boolean $add_default_schedules = true,
  Hash $schedules_hash           = {},
) {

  if $add_default_schedules {
    schedule { 'working_hours':
      range   => '09:00 - 18:00',
    }

    schedule { 'weekend':
      weekday => [ 'Saturday','Sunday'],
    }

    schedule { 'nightly_maintenance':
      range   => '02:00 - 05:00',
    }
  }

  $schedules_hash.each | $k, $v | {
    schedule { $k:
      * => $v,
    }
  }

}
