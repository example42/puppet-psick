#
class psick::iis (
  Hash $features            = {},
  Hash $sites               = {},
  Hash $applications        = {},
  Hash $application_pools   = {},
  Hash $virtual_directories = {},
) {

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
  include ::iis
}
