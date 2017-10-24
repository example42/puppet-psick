# @summary Manage ipsec connections
#
# @param ensure If to create or remove the connection file
# @param options The Hash of ipsec connection options
#
define psick::openswan::connection (
  Hash $options,
  Enum['present','absent'] $ensure = 'present',
  String $template = 'psick/openswan/connection.erb',
  Optional[String] $secret = undef,
) {

  tp::conf { "openswan::${title}.conf":
    ensure  => $ensure,
    mode    => '0400',
    content => template($template),
  }

  if $secret {
    tp::conf { "openswan::${title}.secrets":
      ensure  => $ensure,
      mode    => '0400',
      content => "${options['left']} ${options['right']}: PSK  \"${secret}\"\n",
    }
  }
}
