#
class psick::sensu (
  Psick::Password $rabbitmq_password,
  Psick::Password $api_password,

  String $api_user                      = 'sensu',
  String $api_host                      = '127.0.0.1',
  String $api_bind                      = '0.0.0.0',
  Integer $api_port                     = 4567,

  String $rabbitmq_host                 = '127.0.0.1',
  String $rabbitmq_user                 = 'sensu',
  String $rabbitmq_vhost                = '/sensu',

  Variant[String,Array] $subscriptions  = 'base',
  String $client_address                = $::psick::monitor['ip'],
  String $client_name                   = $::psick::monitor['hostname'],

  Boolean $is_client                    = true,
  Boolean $is_server                    = false,
  Boolean $is_api                       = false,

  String $rabbitmq_class                = '',
  String $redis_class                   = '',
  String $dashboard_class               = '',

  Boolean $tp_test                      = $::psick::tp['test_enable'],

  Hash $checks_hash                     = {},
  Hash $checks_params_hash              = {},

  Hash $plugins_hash                    = {},
  Hash $plugins_params_hash             = {},

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    class { '::sensu':
      client            => $is_client,
      server            => $is_server,
      api               => $is_api,
      api_user          => $api_user,
      api_password      => $api_password,
      api_bind          => $api_bind,
      api_host          => $api_host,
      api_port          => $api_port,
      rabbitmq_user     => $rabbitmq_user,
      rabbitmq_password => $rabbitmq_password,
      rabbitmq_vhost    => $rabbitmq_vhost,
      rabbitmq_host     => $rabbitmq_host,
      subscriptions     => $subscriptions,
      client_address    => $client_address,
      client_name       => $client_name,
    }

    if $rabbitmq_class != '' {
      contain $rabbitmq_class

      # 
      rabbitmq_user { $rabbitmq_user:
        admin    => true,
        password => $rabbitmq_password,
      }
      rabbitmq_vhost { $rabbitmq_vhost:
        ensure => present,
      }
      rabbitmq_user_permissions { "${rabbitmq_user}@${rabbitmq_vhost}":
        configure_permission => '.*',
        read_permission      => '.*',
        write_permission     => '.*',
      }
    }

    if $dashboard_class != '' {
      contain $dashboard_class
    }

    if $redis_class != '' {
      contain $redis_class
    }

    if $checks_hash != {} {
      $checks_hash.each | $k,$v | {
        ::sensu::check { $k:
          * => $checks_params_hash + $v,
        }
      }
    }
    if $plugins_hash != {} {
      $plugins_hash.each | $k,$v | {
        ::sensu::plugin { $k:
          * => $plugins_params_hash + $v,
        }
      }
    }

    # We like sensu module, but we may want to tp test its resources
    # According to the installed components
    if $tp_test {
      $service_client = $is_client ? {
        true  => ['sensu-client'],
        false => [],
      }
      $service_api = $is_api ? {
        true  => ['sensu-api'],
        false => [],
      }
      $service_server = $is_server ? {
        true  => ['sensu-server'],
        false => [],
      }
      $logfile_client = $is_client ? {
        true  => ['/var/log/sensu/sensu-client.log'],
        false => [],
      }
      $logfile_api = $is_api ? {
        true  => ['/var/log/sensu/sensu-api.log'],
        false => [],
      }
      $logfile_server = $is_server ? {
        true  => ['/var/log/sensu/sensu-server.log'],
        false => [],
      }

      tp::install { 'sensu':
        manage_package => false,
        manage_service => false,
        settings_hash  => {
          'service_name'  => $service_client + $service_api + $service_server,
          'log_file_path' => $logfile_client + $logfile_api + $logfile_server,
        },
      }
    }
  }
}
