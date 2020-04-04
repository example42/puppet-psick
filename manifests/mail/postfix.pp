# This class manages the installation and configuration of postfix via tp
#
# @param ensure If to install or remove the postfix package
# @param config_dir_source The source to use (as used in source =>) to populate
#                          the whole postfix configuration directory
# @param config_file_template The erb template (as used in template()) to manage
#                             the content of the postfix main.cf file
# @param options An open hash of options to use in the provided template.
#                Note: This variable is not a class paramenter but it's looked
#                up with lookup('psick::logs::postfix::options', {} )
#
class psick::mail::postfix (
  Enum['present','absent'] $ensure                     = 'present',

  Variant[String[1],Undef] $config_dir_source          = undef,
  String                   $config_file_template       = '',
  Boolean $manage             = $::psick::manage,
  Boolean $noop_manage        = $::psick::noop_manage,
  Boolean $noop_value         = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $options_default = {
      'mydomain'        => $::domain,
      'inet_interfaces' => 'localhost',
      'inet_protocols'  => 'all',
      'my_destination'  => '$myhostname, localhost.$mydomain, localhost',
    }
    $options_user=lookup('psick::mail::postfix::options', Hash, 'deep', {} )
    $options=merge($options_default,$options_user)

    # Postfix as local mailer
    ::tp::install { 'postfix':
      ensure => $ensure,
    }

    if $config_file_template != '' {
      ::tp::conf { 'postfix':
        ensure       => $ensure,
        template     => $config_file_template,
        options_hash => $options,
      }
    }

    ::tp::dir { 'postfix':
      ensure => $ensure,
      source => $config_dir_source,
    }
  }
}
