#
class psick::mongo::tp (
  String                 $template           = 'psick/mongo/mongod.conf.erb',
  String                 $ensure             = $::psick::mongo::ensure,
  Variant[Undef,String]  $key                = $::psick::mongo::key,
  Variant[Undef,String]  $default_password   = $::psick::mongo::default_password,
  String                 $replset            = $::psick::mongo::replset,
  String                 $replset_arbiter    = $::psick::mongo::replset_arbiter,
  Array                  $replset_members    = $::psick::mongo::replset_members,
  Variant[Undef,Hash]    $databases          = undef, # $::psick::mongo::databases,
  Variant[Undef,Hash]    $hostnames          = $::psick::mongo::hostnames,
  Boolean                $initial_master     = false,
  Boolean                $initial_router     = false,
  Array                  $shards             = [],
  Boolean                $auto_replica_setup = true,

  Variant[Undef,String]  $repo               = 'mongodb-org-3.2',
  String                 $mongos_template    = '',
) {

  $options=lookup('psick::mongo::tp::options', Hash, 'deep', { })
  $settings=lookup('psick::mongo::tp::settings', Hash, 'deep', { })

  $tp_settings = tp_lookup('mongodb','settings','tinydata','merge')
  $custom_settings = {
    package_name => 'mongodb-enterprise',
    service_name => 'mongod',
    config_file_path => '/etc/mongod.conf',
  }
  $all_settings = $tp_settings + $custom_settings + $settings

  $default_options = {
    bindIp          => $::ipaddress,
    keyFile         => $key ? { undef => '' , default => '/etc/mongo.key' },
    replSetName     => $replset,
    port            => '27017',
    dbPath          => '/data/mongodb',
    journal_enabled => true,
    storage         => true,
    sharding        => '',
    configDB        => '', # TODO: Calculate automatically
  }
  $all_options = $default_options + $options
  ::tp::install { 'mongodb':
    auto_repo     => false,
    settings_hash => $all_settings,
  }

  Psick::Mongo::Command {
    run_command => $auto_replica_setup,
    db_host     => $::ipaddress,
    db_port     => $all_options['port'],
  }

  psick::tools::create_dir { $all_options['dbPath']:
    owner => $all_settings['process_user'],
    group => $all_settings['process_group'],
  }

  if $template != '' {
    ::tp::conf { 'mongodb':
      template      => $template,
      options_hash  => $all_options,
      settings_hash => $all_settings,
    }
  }
  if $key {
    ::tp::conf { 'mongodb::key':
      path          => '/etc/mongo.key',
      content       => $key,
      mode          => '0400',
      owner         => $all_settings['process_user'],
      group         => $all_settings['process_group'],
      settings_hash => $all_settings,
    }
  }


  # Quick and dirty TODO Automate mongo servers lookup
  if $hostnames {
    $hostnames.each|$ho,$ho_options| {
      host { $ho:
        ip     => $ho_options['ip'],
        before => Tp::Install['mongodb'],
      }
    }
  }

  if $all_options['replSetName'] != '' and $initial_master and $replset_members != [] {
    # Replica Setup
    psick::mongo::command { 'initiate_replicaset':
      template => 'psick/mongo/initiate_replicaset.js.erb',
      options  => {
        replSetName => $all_options['replSetName'],
        firstMember => $replset_members[0],
      },
    }
  }

  if $all_options['replSetName'] != '' and $initial_master and $replset_members != [] {
    # Replica members add
    $additional_members=$replset_members - $replset_members[0]
    $additional_members.each |$member| {
      psick::mongo::command { "add_member_${member}":
        template => 'psick/mongo/add_member.js.erb',
        options  => {
          member => $member,
        },
      }
    }
  }

  if $all_options['replSetName'] != '' and $initial_master and $replset_arbiter != '' {
    # Arbiter add
    psick::mongo::command { 'add_arbiter':
      template => 'psick/mongo/add_arbiter.js.erb',
      options  => { 'arbiter' => $replset_arbiter } ,
    }
  }

  if $initial_router and $shards != [] {
    # Replica members add
    $shards.each |String $shard| {
      $safe_shard=regsubst($shard, '/', '_', 'G')
      psick::mongo::command { "add_shard_${safe_shard}":
        template => 'psick/mongo/add_shard.js.erb',
        options  => {
          shard => $shard,
        },
      }
    }
  }

  if $databases {
    $databases.each|$db,$db_options| {
      $default_options = {
        user          => "${db}_user",
        roles         => [ 'readWrite' ],
        password_hash => mongodb_password("${db}_user",pick_default($db_options['password'],$default_password)),
        tries         => 10,
      }
      $real_options = $db_options + $default_options
      mongodb_database { $db:
        ensure  => 'present',
        tries   => $real_options['tries'],
        require => Tp::Install['mongodb'],
      }
      mongodb_user { $real_options['user']:
        ensure        => 'present',
        database      => $db,
        tries         => $real_options['tries'],
        roles         => $real_options['roles'],
        password_hash => $real_options['password_hash'],
        require       => Tp::Install['mongodb'],
      }
    }
  }

  if $mongos_template != '' {
    file { '/lib/systemd/system/mongos.service':
      ensure  => $ensure,
      content => template($mongos_template),
    }
  }
}
