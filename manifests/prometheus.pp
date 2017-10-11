# class psick::prometheus
#
# Management of Prometheus server
#
# @param alerts: specify alert settings as an array
#
class psick::prometheus (
  Array $alerts = [],
){
  class { '::prometheus':
    manage_user    => true,
    manage_group   => true,
    user           => 'prometheus',
    group          => 'prometheus',
    version        => '1.7.1',
    bin_dir        => '/opt/prometheus/prometheus-1.7.1.linux-amd64',
    shared_dir     => '/opt/prometheus/prometheus-1.7.1.linux-amd64',
    localstorage   => '/opt/prometheus-data',
    extra_options  => '-alertmanager.url http://localhost:9093 -web.console.templates=/opt/prometheus-1.7.1.linux-amd64/consoles -web.console.libraries=/opt/prometheus-1.7.1.linux-amd64/console_libraries',
    install_method => 'package',
    package_name   => 'prometheus',
    package_ensure => present,
    scrape_configs => [
      {
        'job_name'        => 'prometheus',
        'scrape_interval' => '30s',
        'scrape_timeout'  => '30s',
        'file_sd_configs' => [
          {
            'files' => ['/etc/prometheus/files.d/*.json'],
          },
        ],
        'static_configs'  => [
          {
            'targets' => ['localhost:9090'],
            'labels'  => {
              'alias' =>'Prometheus',
            },
          },
        ],
      },
    ],
    alerts         => $alerts,
    rule_files     => ['alert.rules', 'precomputed.rules'],
  }
  file {'/etc/prometheus/precomputed.rules':
    ensure  => file,
    content => epp('psick/prometheus/prometheus_server_precomputed.rules.epp'),
    notify  => Service['prometheus'],
  }
  file { '/etc/prometheus/files.d':
    ensure  => directory,
    purge   => true,
    recurse => true,
  }
  File <<| tag == 'psick::prometheus::node_exporter' |>>
}

