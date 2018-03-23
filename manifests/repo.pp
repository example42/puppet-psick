# Generic repo management wrapper class
# Repos to create, besides default ones (when use_defaults = true)
# are looked up via hiera_hash
#
class psick::repo (
  Optional[String] $auto_conf = undef,
  Boolean $use_defaults       = true,
  String $yum_resource        = 'yumrepo',     # Native resource type
  Hash $yum_repos             = {},
  String $apt_resource        = 'apt::source', # From puppetlabs-apt
  Hash $apt_repos             = {},
  String $zypper_resource     = 'zypprepo',    # From darin-zypprepo
  Hash $zypper_repos          = {},
) {

  if $auto_conf {
    deprecation('psick::repo::auto_conf', 'psick::repo: auto_conf parameter has been deprecated and been replaced by use_defaults')
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
