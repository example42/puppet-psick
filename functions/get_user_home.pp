# This function returns the home directory of the given user
# handling superuser and OS differences
#
# @example
#
#  $home_dir_path = psick::get_user_home($user)
#
function psick::get_user_home ( String[1] $user ) >> String {
  case $::osfamily {
    'RedHat', 'Suse': {
      if $user == 'root' {
        $home_dir = '/root'
      } else {
        $home_dir = "/home/${user}"
      }
    }
    'Solaris': {
      if $user == 'root' {
        $home_dir = $operatingsystemrelease ? {
          '5.11'  => '/root',
          default => '/',
        }
      } else {
        $home_dir = "/home/${user}"
      }
    }
    'windows': {
      $home_dir = "C:/Users/${user}"
    }
    default: {
      if $user == 'root' {
        $home_dir = '/root'
      } else {
        $home_dir = "/home/${user}"
      }
    }
  }
}

