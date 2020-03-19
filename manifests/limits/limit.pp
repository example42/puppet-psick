# @summary Manages a limit file in the /etc/security/limits.d directory
#
# Title of the define can have format like: domain/item otherwise the relevant
# parameters have to be defined.
#
# @param domain The limit domain., Can be: a user, a group (with@group) syntax,
#               an asterisk (*) for default entry
# @param item The limit item. Can be any valid limit type (non validation
#             enforced). Examples: core, data, fsize, memlock, nofile, rss,
#             stack, cpu, nproc, as, maxlogins, maxsyslogins, priority, locks
#             sigpending, msgqueue, nice, rtprio
# @param hard The value for the hard limit
# @param soft The value for the soft limit
# @param both The value for both soft and hard limit
#
# @example Set nofile limits for all users
#   psick::limits::limit { '*/nofile':
#     hard => 20000,
#     soft => 10000,
#   }
# @example Set nproc limits for root user
#   psick::limits::limit { 'root/nproc':
#     soft => 'unlimited',
#   }
#
# @example Set nproc limits for all users, with custom title
#   psick::limits::limit { 'nproc':
#     domain => '*',
#     soft   => 4096,
#   }
define psick::limits::limit (
  Enum['absent', 'present']     $ensure     = present,
  Optional[String]              $domain     = undef,
  Optional[String]              $item       = undef,
  Variant[Integer,String,Undef] $hard       = undef,
  Variant[Integer,String,Undef] $soft       = undef,
  Variant[Integer,String,Undef] $both       = undef,
) {

  include ::psick::limits

  if $ensure == 'present' {
    unless $hard or $soft or $both { fail('You have to define one of $hard, $soft or $both') }
  }
  unless $title =~ /\// {
    unless $domain and $item { fail('If title is not in $domain/item format, $domain and $item are required') }
  }

  $title_split = split($title, '/')
  $real_domain = pick($domain, $title_split[0])
  $real_item = pick($item, $title_split[1])

  if $title !~ /\// {
    $file_path = "${::psick::limits::limits_dir_path}/${title}.conf"
  } else {
    if $real_domain == '*' {
      $file_path = "${::psick::limits::limits_dir_path}/default_${real_item}.conf"
    } else {
      $file_path = "${::psick::limits::limits_dir_path}/${real_domain}_${real_item}.conf"
    }
  }

  file { $file_path:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    content => template('psick/limits/limit.erb'),
  }
}
