# This class manages prerequisites on Ubuntu systems
#
class psick::pre::ubuntu (
  String $repo_url = '',
  String $proxy = hiera('http_proxy',''),
)  {

  # TODO: Configure Apt proxy
  # TODO: Add local repos
}
