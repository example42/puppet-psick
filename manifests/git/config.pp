# = Define: psick::git::config
#
# This define configures the gitconfig file, either for the specified
# user, or, if provided, in the given path.
#
# == Parameters
#
# [*content*]
#   Sets the value of content parameter for the gitconfig file.
#   Can be set as an array (joined with newlines)
#
# [*source*]
#   Sets the value of source parameter for the gitconfig file
#
# [*template*]
#   Sets the value of content parameter for the gitconfig file
#   Note: This option is alternative to the source one
#
# [*ensure*]
#   Define if the gitconfig file should be present (default) or 'absent'
#
# [*user*]
#   Set the user for which to create a gitconfig file. Default is taken from
#   the title.
#
# [*path*]
#   Set the path of the git config file (this overrides any path derived from
#   user parameter
#
# [*options_hash*]
#   Custom hash of options to use in templates.
#
define psick::git::config (
  Enum['present','absent'] $ensure       = present,
  Variant[Undef,String]    $content      = undef,
  Variant[Undef,String]    $template     = 'psick/generic/inifile_with_stanzas.erb',
  Variant[Undef,String]    $source       = undef,
  Optional[String]         $user         = undef,
  Optional[String]         $path         = undef,
  Hash                     $options_hash = {},
) {

  $user_real = $user ? {
    undef    => $title,
    default => $user,
  }

  # $parameters is used in the default generic template
  $parameters = $options_hash

  # Define the final content: if $content is set a line break is added at the
  # end, if not, the $template is used, if set.
  $real_content = $content ? {
    undef     => $template ? {
      undef   => undef,
      default => template($template),
    },
    default   => inline_template('<%= [@content].flatten.join("\n") + "\n" %>'),
  }

  $path_real = $path ? {
    undef   => $user_real ? {
      'root'  => "/${user_real}/.gitconfig",
      default => "/home/${user_real}/.gitconfig",
    },
    default => $path,
  }

  file { $path_real:
    ensure  => $ensure,
    owner   => $user_real,
    group   => $user_real,
    mode    => '0640',
    content => $real_content,
    source  => $source,
  }

}
