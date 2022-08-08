# @summary Creates a systemd unit file
#
# @api public
#
# @see systemd.unit(5)
#
# @param name [Pattern['^[^/]+\.(service|socket|device|mount|automount|swap|target|path|timer|slice|scope)$']]
#   The target unit file to create
#
# @param ensure
#   The state of the unit file to ensure
#
# @param path
#   The main systemd configuration path
#
# @param content
#   The full content of the unit file
#
#   * Mutually exclusive with ``$source``
#
# @param source
#   The ``File`` resource compatible ``source``
#
#   * Mutually exclusive with ``$content``
#
# @param target
#   If set, will force the file to be a symlink to the given target
#
#   * Mutually exclusive with both ``$source`` and ``$content``
#
# @param owner
#   The owner to set on the unit file
#
# @param group
#   The group to set on the unit file
#
# @param mode
#   The mode to set on the unit file
#
# @param show_diff
#   Whether to show the diff when updating unit file
#
# @param enable
#   If set, will manage the unit enablement status.
#
# @param active
#   If set, will manage the state of the unit.
#
# @param restart
#   Specify a restart command manually. If left unspecified, a standard Puppet service restart happens.
#
# @param selinux_ignore_defaults
#   maps to the same param on the file resource for the unit. false in the module because it's false in the file resource type
#
# @param service_parameters
#   hash that will be passed with the splat operator to the service resource
#
# @example manage unit file + service
#   systemd::unit_file { 'foo.service':
#     content => file("${module_name}/foo.service"),
#     enable  => true,
#     active  => true,
#   }
#
define psick::systemd::unit_file (
  Enum['present', 'absent', 'file']         $ensure    = 'present',
  Stdlib::Absolutepath                     $path      = '/etc/systemd/system',
  Optional[Variant[String, Sensitive[String], Deferred]] $content = undef,
  Optional[String]                         $source    = undef,
  Optional[Stdlib::Absolutepath]           $target    = undef,
  String                                   $owner     = 'root',
  String                                   $group     = 'root',
  String                                   $mode      = '0444',
  Boolean                                  $show_diff = true,
  Optional[Variant[Boolean, Enum['mask']]] $enable    = undef,
  Optional[Boolean]                        $active    = undef,
  Optional[String]                         $restart   = undef,
  Boolean                                  $selinux_ignore_defaults = false,
  Hash[String[1], Any]                     $service_parameters = {},
) {
  include psick::systemd

  assert_type(Psick::Systemd::Unit, $name)

  if $enable == 'mask' {
    $_target = '/dev/null'
  } else {
    $_target = $target
  }

  if $_target {
    $_ensure = 'link'
  } else {
    $_ensure = $ensure ? {
      'present' => 'file',
      default   => $ensure,
    }
  }

  file { "${path}/${name}":
    ensure                  => $_ensure,
    content                 => $content,
    source                  => $source,
    target                  => $_target,
    owner                   => $owner,
    group                   => $group,
    mode                    => $mode,
    show_diff               => $show_diff,
    selinux_ignore_defaults => $selinux_ignore_defaults,
  }

  if $enable != undef or $active != undef {
    service { $name:
      ensure   => $active,
      enable   => $enable,
      restart  => $restart,
      provider => 'systemd',
      *        => $service_parameters,
    }

    if $ensure == 'absent' {
      if $enable or $active {
        fail("Can't ensure the unit file is absent and activate/enable the service at the same time")
      }
      Service[$name] -> File["${path}/${name}"]
    } else {
      File["${path}/${name}"] ~> Service[$name]
    }
  } else {
    # Work around https://tickets.puppetlabs.com/browse/PUP-9473
    # and react to changes on static unit files (ie: .service triggered by .timer)
    exec { "${name}-systemctl-daemon-reload":
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      path        => $facts['path'],
      subscribe   => File["${path}/${name}"],
    }
  }
}
