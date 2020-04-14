# This class installs and configures via tp the gitlab-cli tool, used to
# compare Puppet catalogs from different sources
#
# @param ensure Define if to install (present), remove (absent) or the version
#   of the gitlab-cli gem
# @param auto_prereq Define if to automatically install the prerequisites
#   needed by gitlab-cli
# @param epp The path of the epp template (as used in epp()) to use
#   as content for the gitlab-cli configuration file. Note that this file is not an
#   official file for gitlab-cli.
#   It's used by scripts executed in CI steps involving merge request and accept
#   operations.
#
# @param template The path of the erb template (as used in template() to use
#  as content for gitlab-cli config file. This is alternative to epp.
#
# @param config_hash An open hash of options you can use in your template. Note that
#   this hash is merged with an hash of default options provided in the class
#
class psick::gitlab::cli (
  String           $ensure      = 'present',
  Boolean          $auto_prereq = $::psick::auto_prereq,
  Optional[String] $epp         = 'psick/gitlab/cli/gitlab-cli.conf.epp',
  Hash             $config_hash = {},
  Hash   $multirepo_config_hash = {},

  String $scripts_owner         = 'gitlab-runner',
  String $scripts_group         = 'gitlab-runner',
  String $scripts_mode          = '0550',

  Boolean $manage               = $::psick::manage,
  Boolean $noop_manage          = $::psick::noop_manage,
  Boolean $noop_value           = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $default_hash = {
      project_id => '',
      private_token => '',
      api_endpoint => "https =>//gitlab.${::facts['networking']['domain']}/api/v3",
      httparty_options => '{verify: false}',
      assigned_user => '',
      milestone => '',
      labels => 'automerge',
      add_target_label => false,
      add_source_label => false,
      prefix_target_label => 'TO_',
      prefix_source_label => 'FROM_',
    }
    $options = $default_hash + $config_hash
    $yaml_options = { 'defaults' => $default_hash } + $multirepo_config_hash 

    ::tp::install { 'gitlab-cli' :
      ensure      => $ensure,
      auto_prereq => $auto_prereq,
    }

    if $config_hash != {} {
      file { '/etc/gitlab-cli.conf':
        ensure  => $ensure,
        content => epp($epp),
        mode    => '0440',
        owner   => $scripts_owner,
        group   => $scripts_group,
      }
      file { '/usr/local/bin/gitlab_create_merge_request.rb':
        ensure => $ensure,
        source => 'puppet:///modules/psick/gitlab/cli/gitlab_create_merge_request.rb',
        mode   => $scripts_mode,
        owner  => $scripts_owner,
        group  => $scripts_group,
      }
      file { '/usr/local/bin/gitlab_accept_merge_request.rb':
        ensure => $ensure,
        source => 'puppet:///modules/psick/gitlab/cli/gitlab_accept_merge_request.rb',
        mode   => $scripts_mode,
        owner  => $scripts_owner,
        group  => $scripts_group,
      }
    }
    if $multirepo_config_hash != {} {
      file { '/etc/gitlab-cli.yaml':
        ensure  => $ensure,
        content => to_yaml($yaml_options),
        mode    => '0440',
        owner   => $scripts_owner,
        group   => $scripts_group,
      }
      file { '/usr/local/bin/gitlab_multirepo_create_merge_request.rb':
        ensure => $ensure,
        source => 'puppet:///modules/psick/gitlab/cli/gitlab_multirepo_create_merge_request.rb',
        mode   => $scripts_mode,
        owner  => $scripts_owner,
        group  => $scripts_group,
      }
      file { '/usr/local/bin/gitlab_multirepo_accept_merge_request.rb':
        ensure => $ensure,
        source => 'puppet:///modules/psick/gitlab/cli/gitlab_multirepo_accept_merge_request.rb',
        mode   => $scripts_mode,
        owner  => $scripts_owner,
        group  => $scripts_group,
      }
    }
  }
}
