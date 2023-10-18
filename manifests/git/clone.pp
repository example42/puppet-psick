# This define uses tp to git clone a repository and eventually keep it updated
#
define psick::git::clone (
  String $path,
  String $source,
  String $ensure              = 'present',
  Optional[String] $cron_pull = undef,
  String $user                = 'root',
  String $owner               = 'root',
  String $group               = 'root',
  Optional[String] $mode      = undef,
  Optional[String] $git_pubkey_path = undef,
  Optional[String] $revision  = undef,
  Optional[String] $repo_dir  = undef,
  String $post_sync_command   = '', # lint:ignore:params_empty_string_assignment
) {
  $safe_path = regsubst($path,'/', '_', 'G')

  $clone_path = $repo_dir ? {
    undef   => $path,
    default => "/var/tmp/${safe_path}"
  }
  exec { "git_clone move ${title}":
    creates => "${clone_path}/.git",
    command => "[ -d ${clone_path} ] && mv ${clone_path} ${clone_path}_bak || true",
    before  => Tp::Dir["git_clone ${title}"],
    path    => $facts['path'],
  }
  tp::dir { "git_clone ${title}":
    ensure          => $ensure,
    path            => $clone_path,
    source          => $source,
    vcsrepo         => git,
    vcsrepo_options => delete_undef_values({
        identity => $git_pubkey_path,
        user     => $user,
        revision => $revision,
    }),
    owner           => $owner,
    group           => $group,
    mode            => $mode,
  }

  exec { "git_sync ${title}":
    command     => "cd ${clone_path} && git pull",
    cwd         => $clone_path,
    refreshonly => true,
    path        => $facts['path'],
    subscribe   => Tp::Dir["git_clone ${title}"],
    user        => $owner,
    provider    => 'shell',
  }

  if $repo_dir != undef {
    $clone_sync = "rsync -a --delete ${clone_path}/${repo_dir}/ ${path}"
    exec { "git_clone sync ${title}":
      command     => $clone_sync,
      refreshonly => true,
      path        => $facts['path'], # This is the fact $facts['path']
      subscribe   => [Tp::Dir["git_clone ${title}"], Exec["git_sync ${title}"]],
      user        => $owner,
    }
  } else {
    $clone_sync = ''
  }

  $cron_safe_path = regsubst($safe_path,'\.', '_', 'G')
  if $cron_pull {
    $cron_content= @("CRON"/L)
      # File managed by Puppet
      SHELL=/bin/bash
      PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
      MAILTO=''
      ${cron_pull} ${owner} /usr/local/bin/sync_${cron_safe_path}
      | CRON

    file { "/etc/cron.d/sync_${cron_safe_path}":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $cron_content,
    }
  } else {
    file { "/etc/cron.d/sync_${cron_safe_path}":
      ensure  => absent,
    }
  }

  $sync_content= @("SYNC"/L)
    # File managed by Puppet
    SHELL=/bin/bash
    PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
    cd ${clone_path} && git pull ; ${clone_sync}
    ${post_sync_command}
    | SYNC
  file { "/usr/local/bin/sync_${cron_safe_path}":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $sync_content,
  }
}
