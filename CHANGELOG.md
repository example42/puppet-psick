## Changelog

* Your contribution here.

## Release 0.8.0
* Standardised manage, noop_manage and noop_value on all classes
* Removed local tp profiles (replaced by separated tp_profiles module)
* Added psick::limits class
* Added psick::mounts class
* Added option to manage gitlab configs via in line settings
* Cleaned up deprecations in logs
* Removed deprecated auto_conf param

## Release 0.7.0
* Deprecated local tp profiles. Preparing transition to tp_profile module
* Added psick::icinga2 profile, features full
* Added psick::icingaweb2 profile, features full
* Added psick::java:install_tarball define
* Added psick::selinux class
* Added psick::remediate profile to install Puppet Remediate
* Added psick::ensure2* functions
* Added psick::hosts::puppetdb profile.
* psick::php::fpm profile
* Improved psick::packages
* Fixed mariadb and mysql defines
* Puppetserver 6 has new ca commands - [@tuxmea](https://github.com/tuxmea).
* Updated hiera.yaml with globs to split per profile hiera data

## Release 0.6.2
* Updated psick::puppet::foss_master to Puppet 6
* Updated psick::puppetserver to Puppet 6
* Added psick::jenkins::jcasc clsss
* Updated .travis.yml

## Release 0.6.1
* Improved openssh defines
* Added extra_packages_list to psick::git
* Added extra options to default apache vhost template
* Added update_hostname option to psick::hostname
* Less default vagrant plugins
* psick::virtualbox updated

## Release 0.6.0
* Added no_noop parameter to tp profiles
* Changed current no_noop params to not override server side noop_mode
* Added psick::chruby profile
* Use correct puppet agent parameter for server - [@tuxmea](https://github.com/tuxmea).

## Release 0.5.8

* Global renaming auto_prerequisites to auto_prereq #61
* Added force_ordering param to psick #55
* Docs, test and addons to psick::puppet::gems and psick::rbenv #50 #47

## Release 0.5.7

* psick::rbenv profile
* Improved r10k setup

## Release 0.5.6

* psick::gitlab::ci profile
* Puppet profiles from example42 puppet module
* More works on jenkins and Jenkinsfile
* psick::puppet::postrun_command management
* Added no_noop parameter to tp and other profiles
* Added psick::schedule profile
* Added psick::lvm profile
* Added defines to manage services scripts

## Release 0.5.5

* Improved psick::jenkins and psick::jenkins::plugin
* Reorganised docs
* Added psick::reboot profile
* Improved psick::nfs profiles
* Regenerated tp profiles

## Release 0.5.4

* Refactored psick::jenkins profile (psick::ci::jenkins removed)
* Allow alternative pdk templates for mass generation of tp profiles
* Reduced number of redundant tests on tp profiles
* Added ansible and sysdig tp profiles

## Release 0.5.3

* Complete psick::bolt profile and better tasks [@alvagante](https://github.com/alvagante)

## Release 0.5.2

* Added sample Puppet tasks and psick::bolt [@alvagante](https://github.com/alvagante)


## Release 0.5.1

* Improvements and fixes [@alvagante](https://github.com/alvagante)


## Release 0.5.0

* Added lamp classes and defines (apache, php, mariadb, mysql) [@alvagante](https://github.com/alvagante)
* Refactored tp profiles [@alvagante](https://github.com/alvagante)
* Refactored users and packages profiles [@alvagante](https://github.com/alvagante)
* Added ansible and docker profiles and defines [@alvagante](https://github.com/alvagante)

## Release 0.4.0

* Refined and adapted structure to a single standalone module [@alvagante](https://github.com/alvagante)
* Imported defines from Psick 0.3.0 control-repo tools module [@alvagante](https://github.com/alvagante)
* Generate first set of tp profiles with working specs and implementation [@alvagante](https://github.com/alvagante)

## Release 0.3.0

* Sync from Psick 0.3.0 control-repo profile module [@alvagante](https://github.com/alvagante)
