# This class defines Puppet schedules which might be used in
# other parts of the code.
#
class psick::schedule (
  Boolean $add_default_schedules = true,
  Hash $schedules_hash           = {},
  Optional[Integer] $repeat      = undef,
) {

  Schedule {
    repeat => $repeat,
  }

  if $add_default_schedules {
    schedule { 'working_hours':
      range => '09:00 - 18:00',
    }

    schedule { 'weekend':
      weekday => ['sat','sun'],
    }

    schedule { 'working_days':
      weekday => ['mon','tues','wed','thurs','fri'],
      repeat  => 2,
    }

    schedule { 'nightly_maintenance':
      range => '02:00 - 05:00',
    }

    schedule { 'evening':
      range => '21:00 - 0:00',
    }
  }

  $schedules_hash.each | $k, $v | {
    schedule { $k:
      * => $v,
    }
  }

}
