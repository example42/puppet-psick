# Define psick::influxdb::grant
# 
# @summary This define manages user grants on influxdb
#
# @example Manages grants for a user on local server
#   psick::influxdb::grant { 'joe':
#     database        => 'my_db',
#     privilege       => 'READ',
#   }
#
# @example Manages grants on remote server
#   psick::influxdb::grant { 'joe':
#     database        => 'my_db',
#     privilege       => 'READ',
#     server_host     => 'influxdb',
#     server_user     => 'admin',
#     server_password => 'pw'
#   }
#
#  @param user The user for which to manage grants. Default is $title
#  @param database The database to use
#  @param privilege The privileges to grant
#  @param ensure If to create or remove the grant
#  @param server_host The host of the influxdb server to connect to.
#    If not specified influx cli defaults are used.
#  @param server_port The port of the influxdb server to connect to.
#    If not specified influx cli defaults are used.
#  @param server_user The user to use to connect to server.
#    If not specified influx cli defaults are used.
#  @param server_password The password of the connection user.
#    If not specified influx cli defaults are used.
#  @param exec_params An hash of params to set or override the
#    arguments passed to the exec resources which runs
#    influx command.
#
define psick::influxdb::grant (
  String                    $database,
  String                    $user         = $title,
  Enum['present', 'absent'] $ensure       = 'present',
  Enum['READ', 'WRITE', 'ALL'] $privilege = 'ALL',
  Optional[String] $server_host           = 'localhost',
  Variant[Undef,String,Integer] $server_port = undef,
  Optional[String] $server_user           = undef,
  Optional[String] $server_password       = undef,
  Hash $exec_params                       = {},
){

  # Build command line arguments
  $host_param = $server_host ? {
    undef   => '',
    default => "-host '${server_host}'",
  }
  $port_param = $server_port ? {
    undef   => '',
    default => "-port '${server_port}'",
  }
  $password_param = $server_password ? {
    undef   => '',
    default => "-password '${server_password}'",
  }
  $user_param = $server_user ? {
    undef   => '',
    default => "-user '${server_user}'",
  }

  $influx_params = "-database '${database}' ${host_param} ${port_param} ${password_param} ${user_param}"

  if $ensure == 'present' {
    $exec_title = "Influxdb create grant ${title}"
    $_cmd = "GRANT ${privilege} ON ${database} TO ${user}"
    $exec_command = "/usr/bin/influx ${influx_params} -execute \"${_cmd}\""
    $exec_unless  = "/usr/bin/influx -execute \"SHOW GRANTS FOR ${user}\" | grep --perl-regex \"^${database}\s+${privilege}\""
    $exec_onlyif  = undef
  } else {
    $exec_title = "Influxdb revoke grant ${title}"
    $_cmd = "REVOKE ${privilege} ON ${database} TO ${user}"
    $exec_command = "/usr/bin/influx ${influx_params} -execute \"${_cmd}\""
    $exec_unless  = undef
    $exec_onlyif  = "/usr/bin/influx -execute \"SHOW GRANTS FOR ${user}\" | grep --perl-regex \"^${database}\s+${privilege}\""
  }

  # Attempt to autoconfigure dependencies based on server host. Can be
  # overridden with param $exec_params
  $exec_require = $server_host ? {
    /(localhost|127.0.0.1|$fqdn|$hostname|$ipaddress)/ => [Package[influxdb],Service[influxdb]],
    default                                            => [Package[influxdb]],
  }
  $exec_default_options = {
    'command' => $exec_command,
    'unless'  => $exec_unless,
    'onlyif'  => $exec_onlyif,
    'require' => $exec_require,
  }

  exec { $exec_title:
    * => $exec_default_options + $exec_params,
  }

}
