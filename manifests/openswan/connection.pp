# @summary Manage ipsec connections
#
# @param ensure If to create or remove the connection file
# @param options The Hash of ipsec connection options
#
define psick::openswan::connection (
  Hash $options,
  Hash $tp_options                 = {},
  Enum['present','absent'] $ensure = 'present',
  String $template = 'psick/openswan/connection.erb',
  Optional[String] $secret = undef,
) {

  $tp_default_options = {
    ensure  => $ensure,
    mode    => '0400',
  }
  tp::conf { "openswan::${title}.conf":
    content => template($template),
    *       => $tp_default_options + $tp_options,
  }

  if $secret {
    tp::conf { "openswan::${title}.secrets":
      *       => $tp_default_options + $tp_options,
      content => "${options['left']} ${options['right']}: PSK  \"${secret}\"\n",
    }
  }
}
