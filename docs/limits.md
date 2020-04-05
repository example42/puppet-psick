## psick::limits - Manages system limits

This class manages the contents of file /etc/security/limits.conf and the /etc/security/limits.d in order to configure system's limits.

It offers different ways to perform that:

  - Managing the /etc/security/limits.conf contents using a erb or epp template
    (parameters involved: limits_conf_template, parameters and limits_conf_source)
  - Managing the /etc/security/limits.d/ directory contents with th
    limits_dir_source and limits_dir_params parameters
  - Managing single limits files in /etc/security/limits.d/ with the
    parameter limits_hash which creates psick::limits::limit resources
  - Managing single limits files in /etc/security/limits.d/ with the
    parameter configs_hash which creates psick::limits::config resources


Just include the class (by default it manages /etc/security/limits.conf and /etc/security/limits.d
without modifying any content) and then via Hiera configure as follows.

To configure limits files under /etc/security/limits.d  (use parameters from the the tools::limit define)
using an has of key/values looked upo via Hiera via a deep merge mode:

    psick::limits::limits_hash:
      'al/nofile':
        soft: 2048
        hard: 2048

To configure the content of /etc/security/limits.conf using an erb template where you can use variables like
 <%= @parameters['key'] %> to specify the wanted value from the keys in the psick::limits::parameters Hash:

    psick::limits::limits_conf_template: 'psick/limits/limits.conf.epp'
    psick::limits::parameters:
      key: value

To configure the content of /etc/security/limits.conf using a static source file:

    psick::limits::limits_conf_source: 'puppet:///modules/psick/limits/limits.conf'

To configure the contents of the whole /etc/security/limits.d directory with the files present in a defined source:

    psick::limits::limits_dir_source: 'puppet:///modules/psick/limits/limits.d'

To configure the contents of the whole /etc/security/limits.d directory with the files present in a defined source
and force removal of any other file not managed by Puppet (handle with CARE!):

    psick::limits::limits_dir_source: 'puppet:///modules/psick/limits/limits.d'
    psick::limits::limits_dir_params:
      recurse: true
      force: true
      purge: true


