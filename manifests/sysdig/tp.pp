# psick::sysdig::tp
#
# @summary This psick profile manages sysdig with Tiny Puppet (tp)
#
# @example Include it to install sysdig
#   include psick::sysdig::tp
#
# @example Include in PSICK via hiera (yaml)
#   psick::profiles::linux_classes:
#     sysdig: psick::sysdig::tp
#
# @param manage If to actually manage any resource in this profile or not
# @param ensure If to install or remove sysdig. Valid values are present, absent, latest
#   or any version string, matching the expected sysdig package version.
# @param settings_hash An hash of tp settings to override default sysdig file
#   paths, package names, repo info and whatever can match Tp::Settings data type:
#   https://github.com/example42/puppet-tp/blob/master/types/settings.pp
# @param auto_prereq If to automatically install eventual dependencies for sysdig.
#   Set to false if you have problems with duplicated resources, being sure that you
#   manage the prerequistes to install sysdig (other packages, repos or tp installs).
class psick::sysdig::tp (
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,
  Hash            $settings_hash            = {},
  Boolean         $auto_prereq              = $::psick::auto_prereq,
) {

  if $manage {
    # tp::install sysdig
    $install_defaults = {
      ensure        => $ensure,
      settings_hash => $settings_hash,
      auto_repo     => $auto_prereq,
      auto_prereq   => $auto_prereq,
    }
    ::tp::install { 'sysdig':
      * => $install_defaults,
    }

  }
}
