# class psick::keepalived::balanced_host
# Smape class to add to hosts to be balanced by
# psick::keepalived
#
class psick::keepalived::balanced_host (
  String $vip,
  Array $ports,
  String $lb_type               = 'keepalived',
  String $lb_name               = 'default',
  Boolean $lb_active            = true,
  Hash $lb_options              = { },
  Optional[String] $lb_template = undef,
  Boolean $manage               = true,
  Boolean $noop_manage          = false,
  Boolean $noop_value           = false,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $lb_active {
      $default_lb_options = {
        'connect_timeout' => 5,
        'paths'           => [ '/' ],
      }
      $real_lb_options = $default_lb_options + $lb_options
      psick::keepalived::balance { 'default':
        vip         => $vip,
        ports       => $ports,
        lb_options  => $real_lb_options,
        lb_template => $lb_template,
      }
    }
  }
}

