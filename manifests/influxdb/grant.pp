

define psick::influxdb::grant (
  Enum['present', 'absent']    $ensure = 'present',
  Enum['READ', 'WRITE', 'ALL'] $privilege = 'ALL',
  String                       $database,
  String                       $user,
){
  ensure_packages(['influxdb-client'])
  if $ensure == 'present' {
    $_cmd = "GRANT ${privilege} ON ${database} TO ${user}"

    exec {"grant $name":
      command => "/usr/bin/influx -execute \"${_cmd}\" -database ${database}",
      unless  =>  "/usr/bin/influx -execute \"SHOW GRANTS FOR ${user}\" | grep --perl-regex \"^${database}\t${grant}\"",
    }
  } else {
    $_cmd = "REVOKE ${privilege} ON ${database} FROM ${user} "

    exec {"revoke $name":
      command => "/usr/bin/influx -execute \"${_cmd}\" -database ${database}",
      onlyif  => "/usr/bin/influx -execute \"SHOW GRANTS FOR ${user}\" | grep --perl-regex \"^${database}\t${grant}\"",
    }
  }

}
