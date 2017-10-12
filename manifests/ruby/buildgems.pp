# This class installs the packages needed to build gems
#
class psick::ruby::buildgems (
  Array $packages = [],
) {

  $packages.each |$pkg| {
    ensure_packages($pkg)
  }

}
