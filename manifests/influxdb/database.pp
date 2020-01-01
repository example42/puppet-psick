# Define psick::influxdb::database
# 
# @summary This define creates a influxdb database
#
# @example Create a database on local server
#   psick::influxdb::database { 'my_data': }
#
# @example Create a user on remote server
#   psick::influxdb::database { 'my_data': }
#     server_host     => 'influxdb',
#     server_user     => 'admin',
#     server_password => 'pw'
#   }
#
#  @param database The database to manage. Default is = $title
#  @param ensure If to create or remove the database
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
define psick::influxdb::database (
  Enum['present', 'absent'] $ensure = 'present',
  String                  $database = $title,
  Optional[String] $server_host     = 'localhost',
  Variant[Undef,String,Integer] $server_port = undef,
  Optional[String] $server_user     = undef,
  Optional[String] $server_password = undef,
  Hash $exec_params                 = {},
){

  # Build command line arguments
  $host_param = "-host '${server_host}'"
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

  $influx_params = "${host_param} ${port_param} ${password_param} ${user_param}"

  if $ensure == 'present' {
    $exec_title = "Create database ${title}"
    $_cmd = "CREATE DATABASE ${database}"
    $exec_command = "/usr/bin/influx ${influx_params} -execute \"${_cmd}\""
    $exec_unless  = "/usr/bin/influx -execute \"SHOW DATABASES\" | grep --perl-regex \"^${name}\""
    $exec_onlyif  = undef
  } else {
    $exec_title = "Drop database ${title}"
    $_cmd = "DROP DATABASE ${database} "
    $exec_command = "/usr/bin/influx ${influx_params} -execute \"${_cmd}\""
    $exec_unless  = undef
    $exec_onlyif  = "/usr/bin/influx -execute \"SHOW DATABASES\" | grep --perl-regex \"^${name}\t\""
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
