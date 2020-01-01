# Define psick::influxdb::user
# 
# @summary This define creates a influxdb user
#
# @example Create a user on local server
#   psick::influxdb::user { 'joe':
#     database        => 'my_db',
#     password        => 'my_pw',
#   }
#
# @example Create a user on remote server
#   psick::influxdb::user { 'joe':
#     database        => 'my_db',
#     password        => 'my_pw',
#     server_host     => 'influxdb',
#     server_user     => 'admin',
#     server_password => 'pw'
#   }
#
#  @param password The password of the user being created
#  @param database The database to use
#  @param ensure If to create or remove the user
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
define psick::influxdb::user (
  String                    $password,
  String                    $database,
  String                    $user   = $title,
  Enum['present', 'absent'] $ensure = 'present',
  Optional[String] $server_host     = 'localhost',
  Variant[Undef,String,Integer] $server_port = undef,
  Optional[String] $server_user     = undef,
  Optional[String] $server_password = undef,
  Hash $exec_params                 = {},
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
    $exec_title = "Create user ${title}"
    $_cmd = "CREATE USER ${user} WITH PASSWORD '${password}'"
    $exec_command = "/usr/bin/influx ${influx_params} -execute \"${_cmd}\""
    $exec_unless  = "/usr/bin/influx -execute \"SHOW USERS\" | grep --perl-regex \"^${user}\s+\""
    $exec_onlyif  = undef
  } else {
    $exec_title = "Drop user ${title}"
    $_cmd = "DROP USER ${user} "
    $exec_command = "/usr/bin/influx ${influx_params} -execute \"${_cmd}\""
    $exec_unless  = undef
    $exec_onlyif  = "/usr/bin/influx -execute \"SHOW USERS\" | grep --perl-regex \"^${user}\s+\""
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
