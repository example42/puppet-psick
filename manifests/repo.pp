# Generic repo management wrapper class
# Repos to create, besides default ones (when use_defaults = true)
# are looked up via lookup
#
class psick::repo (
  Boolean $use_defaults       = true,
  String $yum_resource        = 'yumrepo',     # Native resource type
  Hash $yum_repos             = {},
  String $apt_resource        = 'apt::source', # From puppetlabs-apt
  Hash $apt_repos             = {},
  String $zypper_resource     = 'zypprepo',    # From darin-zypprepo
  Hash $zypper_repos          = {},

  Boolean $manage             = $::psick::manage,
  Boolean $noop_manage        = $::psick::noop_manage,
  Boolean $noop_value         = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    # Default repos
    if $use_defaults {
      case $::osfamily {
        'RedHat': {
          tp::repo { 'epel': }
        }
        'Debian': {
        }
        'Suse': {
        }
        default: {
        }
      }
    }

    # Not converted to Puppet 4 style for easier variables management.
    if $yum_repos != {} {
      create_resources($yum_resource, $yum_repos)
    }
    if $apt_repos != {} {
      create_resources($apt_resource, $apt_repos)
    }
    if $yum_repos != {} {
      create_resources($zypper_resource, $yum_repos)
    }
  }
}
