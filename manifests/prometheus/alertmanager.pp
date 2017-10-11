# class psick::prometheus::alertmanager
#
# Manages the prometheus server alertmanager
#
# @param mail_rcpt specify an email address which should receive alerts
# @param stmp_smarthost default to localhost
# @param version specify version of alertmanager to use defaults to 0.8.0
#
class psick::prometheus::alertmanager (
  String $mail_rcpt,
  String $smtp_smarthost = 'localhost',
  String $version        = '0.8.0',
){
  class { '::prometheus::alertmanager':
    manage_user    => true,
    manage_group   => true,
    user           => 'prometheus',
    group          => 'prometheus',
    bin_dir        => '/opt/prometheus/alertmanager-0.8.0.linux-amd64',
    version        => $version,
    install_method => 'package',
    package_name   => 'prometheus-alertmanager',
    package_ensure => present,
    route          => {
      group_by        => ['alertname', 'cluster', 'service'],
      group_wait      => '30s',
      group_interval  => '5m',
      repeat_interval => '3h',
      receiver        => 'Admin',
    },
    global         => {
      smtp_smarthost => $smtp_smarthost,
      smtp_from      => "alertmanager@${::facts['networking']['fqdn']}",
    },
    receivers      => [
      {
        name          => 'Admin',
        email_configs => [
          {
            to => $mail_rcpt,
          },
        ],
      },
    ],
  }
}

