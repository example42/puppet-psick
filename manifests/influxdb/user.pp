

define psick::influxdb::user (
  Enum['present', 'absent'] $ensure = 'present',
  String                    $password,
  String                    $database,
){
  ensure_packages(['influxdb-client'])
  if $ensure == 'present' {
    $_cmd = "CREATE USER ${name} WITH PASSWORD '${password}'"

    exec {"create_user_${name}":
      command => "/usr/bin/influx -execute \"${_cmd}\" -database '${database}'",
      unless  =>  "/usr/bin/influx -execute \"SHOW USERS\" | grep --perl-regex \"^${name}\t\"",
    }
  } else {
    $_cmd = "DROP USER ${name} "

    exec {"drop_user_${name}":
      command => "/usr/bin/influx -execute '${_cmd}' -database '${database}'",
      onlyif  =>  "/usr/bin/influx -execute \"SHOW USERS\" | grep --perl-regex \"^${name}\t\"",
    }
  }

}
