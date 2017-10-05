# Define: psick::php::pear::config
#
# @summary Configures pear using pear config-set commands
#
# @example 
# psick::php::pear::config { http_proxy: value => "myproxy:8080" }
#
# @param value The value of the pear setting defined in the title
#
define psick::php::pear::config ($value) {

  exec { "pear-config-set-${title}":
    command => "pear config-set ${title} ${value}",
    unless  => "pear config-get ${title} | grep ${value}",
    require => Class['psick::php::pear'],
  }

}
