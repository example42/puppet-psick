# = Define: psick::limits::config
#
# This define configures a limits file under /etc/security/limits.d
# File name, unless specified by path will be
# "/etc/security/limits.d/${title}.conf"
#
# @param content Sets the value of content parameter for the target file.
# @param source  Sets the value of source parameter for the target file.
# @param template Sets the path of the template to use fot content parameter
# @param ensure If to add or remove the limtis file
# @param path The path of the target file. Default: "/etc/security/limits.d/${title}.conf"
# @param file_params A custom hash of file params to override defaults
# @param options Optional hash of custom key pairs which can be used in template
#
define psick::limits::config (
  Enum['present','absent'] $ensure         = present,
  Variant[Undef,String]    $content        = undef,
  Variant[Undef,String]    $template       = undef,
  Variant[Undef,String]    $source         = undef,
  Optional[String]         $path           = undef,
  Hash                     $file_params    = {},
  Hash                     $options        = {},
) {
  include ::psick::limits

  $file_path = pick($path,"${::psick::limits::limits_dir_path}/${title}.conf")
  $file_params_default = {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => psick::template($template , $options),
    source  => $source,
  }
  file { $file_path:
    * => $file_params_default + $file_params,
  }

}

