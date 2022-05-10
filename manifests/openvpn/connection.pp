# @summary Manage openvpn connections
#
# @param ensure If to create or remove the connection file
# @param options The Hash of ipsec connection options
#
define psick_profile::openvpn::connection (
  Enum['present','absent'] $ensure = 'present',
  String $template                 = 'psick_profile/openvpn/connection.erb',
  Hash $options                    = {},
) {

  tp::conf { "openvpn::${title}.conf":
    ensure       => $ensure,
    mode         => '0400',
    content      => template($template),
    options_hash => $options,
  }

}
