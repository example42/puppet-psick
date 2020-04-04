# Setup a VPC via aws cli
class psick::aws::cli::vpc (
  String  $region                    = $::psick::aws::region,
  String  $ensure                    = 'present',
  String  $default_cidr_block_prefix = $::psick::aws::default_cidr_block_prefix,
  String  $default_vpc_name          = $::psick::aws::default_vpc_name,
  Boolean $create_defaults           = $::psick::aws::create_defaults,
  Boolean $autorun                   = true,
  Hash    $aws_scripts               = { },

  Boolean      $manage               = $::psick::manage,
  Boolean      $noop_manage          = $::psick::noop_manage,
  Boolean      $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $create_defaults {
      $default_aws_scripts = {
        "vpc_${default_vpc_name}" => {
          template    => 'psick/aws/cli/vpc.erb',
        },
      }
    } else {
      $default_aws_scripts = {}
    }
    $all_aws_scripts = $aws_scripts+$default_aws_scripts

    $aws_scripts_defaults = {
      ensure                  => $ensure,
      region                  => $region,
      autorun                 => $autorun,
    }
    if $all_aws_scripts != { } {
      $all_aws_scripts.each | $k,$v | {
        psick::aws::cli::script { $k:
          * => $aws_scripts_defaults + $v,
        }
      }
    }
  }
}
