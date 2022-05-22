## How to upgrade psick to version 1

Version 1 of psick module is not, for some profiles, backwards compatible with 0.x versions.

Many application specific profiles have been moved to the new psick_profile module,
which provides a set of reusable profiles for common applications, merging the functionality of 
the profiles imported from the psick module and the ones of the tp_profile module (now DEPRECATED).

This is the list of the profiles moved from psick to psick_profile module

-   psick::gitlab moved to psick_profile::gitlab
-   psick::mariadb moved to psick_profile::mariadb
-   psick::mysql moved to psick_profile::mysql
-   psick::docker moved to psick_profile::docker
-   psick::apache moved to psick_profile::apache
-   psick::icinga2 moved to psick_profile::icinga2
-   psick::icingaweb2 moved to psick_profile::icingaweb2
-   psick::monitor::sar moved to psick_profile::sar
-   psick::monitor::ganglia moved to psick_profile::ganglia
-   psick::monitor::newrelic moved to psick_profile::newrelic
-   psick::monitor::nrpe moved to psick_profile::nrpe
-   psick::monitor::snmpd moved to psick_profile::snmpd
-   psick::virtualbox moved to psick_profile::virtualbox
-   psick::jenkins moved to psick_profile::jenkins
-   psick::backup::duply moved to psick_profile::duply
-   psick::backup::legato moved to psick_profile::legato
-   psick::ci:octocatalog moved to psick_profile::octocatalog
-   psick::foreman moved to psick_profile::foreman::tp
-   psick::grafana moved to psick_profile::grafana
-   psick::inluxdb moved to psick_profile::influxdb
-   psick::keepalived moved to psick_profile::keepalived
-   psick::mongo moved to psick_profile::mongo
-   psick::prometheus moved to psick_profile::prometheus
-   psick::rundeck moved to psick_profile::rundeck
-   psick::sensu moved to psick_profile::sensu
-   psick::vagrant moved to psick_profile::vagrant
-   psick::iis moved to psick_profile::iis
-   psick::puppetserver moved to psick_profile::puppetserver
-   psick::puppetdb moved to psick_profile::puppetdb
-   psick::mail::postfix moved to psick_profile::postfix

This is a list of tp_profiles moved to psick and psick_profiles

-   tp_profile::openssh moved to psick::openssh::tp
-   tp_profile::postfix moved to psick_profiles::postfix::tp
-   tp_profile::postgresql moved to psick_profiles::postgresql::tp
-   tp_profile::puppetdb moved to psick_profiles::puppetdb::tp
-   tp_profile::puppetserver moved to psick_profiles::puppetserver::tp
-   tp_profile::rabbitmq moved to psick_profiles::rabbitmq::tp
-   tp_profile::redis moved to psick_profiles::redis::tp

### What to do to upgrade

If you use any of the above psick classes, search globally (with Visual Studio Code: Edit -> Find in Files) for them, like "psick::icinga2", and if you find occurrences in your Hiera data, replace with "psick_profile::icinga2".
