# @summary  This define manages an icinga2 configuration file.
#
# This define is just a wrapper around a file resource, by default the
# file is created under /etc/icinga2/zones.d with the resource $title
# as filename and the '.conf' suffix
# To manage the content of the file there are 2 ALTERNATIVE params:
# source and template. Their content is the one expected for a
# normal resource, but if template ends with .epp the epp() function
# is automatically used instead of template()
#
# @param source Sets the value of source parameter for the icinga2 config file
#
# @param template Sets the value of content parameter for the icinga2 config file
#   Note: This option is alternative to the source one
#   If value ends with .epp then it's passed to the epp function
#   If value ends with .erb then it's passed to the epp function
#   If values ends with something else, then it's passwd to the file function.
#   The result is then passed to the content parameter of the file.
#
# @param ensure Define if the icinga2 config file should be present (default) or 'absent'
#
# @param path Set the full path of the icinga2 config file (this overrides the default path:
#   "/etc/icinga2/zones.d/${title}.conf"
#
# @param config_dif Name of the directory, inside /etc/icinga2, where to place
#   config files (when no path is set).
# @param owner The owner of the created directory
# @param group The group of the created directory
# @param mode The mode of the created directory
# @param file_notify If want resource to notify when file changes.
#   By default it notifies icinga2 service, set this to undef to skip the
#   automatic service restart on change.
# @param options_hash Custom hash of options to use in templates.
#   You can access to them in templates under the $options_hash variable
#
define psick::icinga2::config (
  Enum['present','absent'] $ensure       = present,
  Variant[Undef,String]    $template     = undef,
  Variant[Undef,String]    $source       = undef,
  Optional[String]         $path         = undef,
  String                   $config_dir   = 'zones.d',
  String                   $owner        = 'root',
  String                   $group        = 'root',
  String                   $mode         = '0644',
  Optional[String]         $file_notify  = 'Service["icinga2"]',
  Hash                     $options_hash = {},
) {

  $path_real=pick($path,"/etc/icinga2/${config_dir}/${title}.conf")
  file { $path_real:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => psick::template($template, { options_hash => $options_hash }),
    source  => $source,
    notify  => $file_notify,
  }

}
