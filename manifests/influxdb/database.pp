

define psick::influxdb::database (
  Enum['present', 'absent'] $ensure = 'present',
){
  ensure_packages(['influxdb-client'])
  if $ensure == 'present' {
    $cmd_1 = "CREATE DATABASE ${name} "

    exec {"create_db_${name}":
      command => "/usr/bin/influx -execute '${cmd_1}'",
      unless  =>  "/usr/bin/influx -execute \"SHOW DATABASES\" | grep \"^${name}$\"",
    }
  } else {
    $cmd_1 = "DROP DATABASE ${name} "

    exec {"drop_db_${name}":
      command => "/usr/bin/influx -execute '${cmd_1}'",
      onlyif  =>  "/usr/bin/influx -execute \"SHOW DATABASES\" | grep \"^${name}$\"",
    }
  }

}
