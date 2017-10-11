# class psick::prometheus::node_exporter
#
# Manages node entries on prometheus server via exported resources
#
# @param version specify version of node exoprter to use defaults to 0.14.0
#
class psick::prometheus::node_exporter (
  String $version = '0.14.0',
){
  class { '::prometheus::node_exporter':
    manage_user    => true,
    manage_group   => true,
    user           => 'prometheus',
    group          => 'prometheus',
    version        => $version,
    bin_dir        => '/opt/prometheus/node_exporter-0.14.0.linux-amd64',
    install_method => 'package',
    package_name   => 'prometheus-node-exporter',
    package_ensure => present,
  }
  @@file { "/etc/prometheus/files.d/${::facts['networking']['fqdn']}.json":
    ensure  => file,
    content => epp('psick/prometheus/prometheus_node_export.json.epp'),
  }
}
