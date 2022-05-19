# @summary custom datatype that validates different filenames for systemd units
type Psick::Systemd::Unit = Pattern['^[^/]+\.(service|socket|device|mount|automount|swap|target|path|timer|slice|scope)$']
