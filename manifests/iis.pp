#
class psick::iis (
  Hash $features            = {},
  Hash $sites               = {},
  Hash $applications        = {},
  Hash $application_pools   = {},
  Hash $virtual_directories = {},

  Boolean $manage           = $::psick::manage,
  Boolean $noop_manage      = $::psick::noop_manage,
  Boolean $noop_value       = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $features.each | $k,$v | {
      iis_feature { $k:
        * => $v,
      }
    }
    $sites.each | $k,$v | {
      iis_site { $k:
        * => $v,
      }
    }
    $applications.each | $k,$v | {
      iis_application { $k:
        * => $v,
      }
    }
    $application_pools.each | $k,$v | {
      iis_application_pool { $k:
        * => $v,
      }
    }
    $virtual_directories.each | $k,$v | {
      iis_virtual_directory { $k:
        * => $v,
      }
    }
  }
}
