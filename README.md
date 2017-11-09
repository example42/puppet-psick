# PSICK: The Infrastructure Puppet module

[![Build Status](https://travis-ci.org/example42/puppet-psick.png?branch=master)](https://travis-ci.org/example42/puppet-psick)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/503831d4ea6a470e864f1a3969449b78)](https://www.codacy.com/app/example42/puppet-psick?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=example42/puppet-psick&amp;utm_campaign=Badge_Grade)

This is the PSICK (Puppet Systems Infrastructure Construction Kit) module.
 
It is what we call an **Infrastructure** Puppet **module**. It provides:

  - Solid management of **classification**. Entirely hiera driven.
  - An integrated set of **profiles** for common systems management activities
  - A growing number flexible set of **tp profiles** for applications
  - Integrated and automated firewall (WIP) and monitoring management
  - Safe and easy to be integrated in existing setups, cohexists with other modules, allows expandibility by design.
  - Entirely Hiera driven: In practice a DSL to configure infrastructures
 
It can be used together with the [PSICK control-repo](https://github.com/example42/psick) (check the [Hiera data](https://github.com/example42/psick/tree/production/hieradata) there for sample usage patterns) or as a strandalone module, just:

    include psick

This doesn't do anything at all, by default, but is enough to let you manage *everything* via Hiera.

In the following examples we will use Hiera YAML files, but any backend can be used: psick is a normal, even if somehow unusual, Puppet module, with classes (a lot of them) whose params can be set as Hiera data, defines, templates, files, fuctions, custom data types etc.


## Do You Speak Psick?

Psick "language" has the syntax of any Hiera supported backend (here we use YAML), and the semantic you are going to discover here.

The module provides 3 major features:

  - Structured cross-os, staged **classification** 
  - Base **profiles** for common system configurations
  - Standardised and multifunctional **tp profiles** for applications

### Classification

Psick can manage the whole classification of the nodes of an infrastructure. It can work side by side and External Node Classifier, or it can totally replace it.

All you need is to include the psick class and define, using ```${::kernel}_class``` parameters, which classes to include in a node in different phases.

Psick provides 4 phases, managed by the relevant subclasses:

  - **firstrun**, optional phase, in which the resulting catalog is applied only once, at the first Puppet run. After a reboot can optionally be triggered and the real definitive catalog is applied.
  - **pre**, prerequisites classes, they are applied in a normal catalog run (that is, always except in the very first Puppet run, if firstrun is enabled) before all the other classes.
  - **base**, base classes, common to all the nodes (but exceptions can be applied), applied in normal catalog runs after the pre classes and before the profiles.
  - **profiles**, exactly as in the roles and profiles pattern. The profile classes that differentiate nodes by their role or function. Profiles are applied after the base classes are managed.

An example of configurations, both for Linux and Windows nodes that use all the above phases:

    # First run mode must be enabled and each class to include there explicitely defined:
    psick::enable_firstrun: true
    psick::firstrun::linux_classes:
      hostname: psick::hostname
      packages: psick::aws::sdk
    psick::firstrun::windows_classes:
      hostname: psick::hostname
      packages: psick::aws::sdk

    # Pre and base classes, both on Linux and Windows
    psick::pre::linux_classes:
      puppet: ::puppet
      dns: psick::dns::resolver
      hostname: psick::hostname
      hosts: psick::hosts::resource
      repo: psick::repo
    psick::base::linux_classes:
      sudo: psick::sudo
      time: psick::time
      sysctl: psick::sysctl
      update: psick::update
      ssh: psick::openssh::tp
      mail: psick::postfix::tp
      mail: psick::users::ad

    psick::pre::windows_classes:
      hosts: psick::hosts::resource
    psick::base::windows_classes:
      features: psick::windows::features
      registry: psick::windows::registry
      services: psick::windows::services
      time: psick::time
      users: psick::users::ad

    # Profiles for specific roles (ie: webserver)
    psick::profiles::linux_classes:
      webserver: apache
    psick::profiles::windows_classes:
      webserver: iis

The each key-pair of these $kernel_classes parameters contain an arbitrary tag or marker (users, time, services, but could be any string), and the name the class to include.

This name must be a valid class, which can be found in the Puppet Master modulepath (so probably defined in your control-repo ```Puppetfile```): you can use any of the predefinied Psick profiles, or your own local site profiles, or directly classes from public modules and configure them via Hiera in their own namespace.

To manage exceptions and use a different class on different nodes is enough to specify the alternative class name as value for the used marker (here 'ssh'), in the appropriate Hiera file: 

    psick::base::linux_classes:
      ssh: ::profile::ssh_bastion

To completely disable on specific nodes the usage of a class, included in a general hierarhy level, set the class name to an empty string:

    psick::base::linux_classes:
      ssh: ''

This is the classification part, since it's based on class parameters, it can be managed with flexibility via Hiera and can cohexist (even if this might not be an optimal choice) with other classifications methods.

The pre -> base -> profiles order is strictly enforced, so we sure to place your class in the most appropriate phase (even if functionally they all do the same work: include the specified classes) and, to prevent dependency cycles, avoid to set the same class in two different phases.


#### Auto configuration defaults

If you are lazy or want to try some predefined defaults (always WIP) you can simply try to use one of our embedded sets of configurations, note that you can customise and override everything, in your control-repo hiera data.

For example, to use Psick predefined defaults (as in  ```data/default/*.yaml```):

    psick::auto_conf: default

To use, instead, some hardened defaults (as in ```data/hardened/*.yaml```):

    psick::auto_conf: hardened

The auto configuration settings are defined at module level hierarchy, so they can be overwritten in the environment's Hiera data.


### Psick tp profiles

Psick provides out of the box profiles, based on ([Tiny Puppet](https://github.com/example42/puppet-tp), to manage common applications. They can replace or complement component modules when applications can be managed via packeages, services and files.

They have generated from a common [template](https://github.com/example42/pdk-module-template-tp-profile) so have standard parameters, and are always called ```psick::$app::tp```.

For example to configure Openssh both client and server settings we can write something like:

    # By including the psick::openssh::tp profile we install Openssh via tp
    psick::base::linux_classes:
      ssh: 'psick::openssh::tp'

    # To customise the configuration files to manage at their options:
    psick::openssh::tp::resources_hash:
      tp::conf:
        openssh: # The openssh main configuration file
          template: 'profile/openssh/sshd_config.erb'
        openssh::ssh_config # The /etc/ssh/ssh_config file
          epp: 'profile/openssh/ssh_config.epp'

    # To manage the variables referenced in the used templates (the have to map the same keys):
    psick::openssh::options_hash:
      AllowAgentForwarding: yes
      AllowTcpForwarding: yes
      ListenAddress:
        - 127.0.0.1
        - 0.0.0.0
      PasswordAuthentication: yes
      PermitEmptyPasswords: no
      PermitRootLogin: no

Similary we could manage postfix with data like:

    psick::base::linux_classes:
      mail: 'psick::postfix::tp'

    # To customise the configuration files to manage at their options:
    psick::postfix::tp::resources_hash:
      tp::conf:
        postfix: # Postfix's main.cf
          template: 'profile/postfix/main.cf.erb'
        postfix::master.cf # master.cf
          epp: 'profile/postfix/master.cf.erb'


### Psick base profiles

Basides tp profiles, Psick features a large set of profiles for common baseline configurations.

Some of them are intended to be used both on Linux and Windows, others are more specific.

Here follows documentation on how to manage different common system configurations:

  - [psick::hosts::](docs/hosts.md) - Manage /etc/hosts
  - [psick::motd](docs/motd.md) - Manage /etc/motd and /etc/issue
  - [psick::nfs::](docs/nfs.md) - Manage NFS client and server
  - [psick::sudo](docs/sudo.md) - Manage sudo configuration
  - [psick::sysctl](docs/sysctl.md) - Manage sysctl settings
  - [psick::firewall::](docs/firewall.md) - Manage firewalling
  - [psick::openssh::](docs/openssh.md) - tp profile and keygen define
  - [psick::hardening](docs/hardening.md) - Manage system hardening
  - [psick::network](docs/network.md) - Manage networking
  - [psick::puppet::](docs/puppet.md) - Manage Puppet components
  - [psick::users](docs/users.md) - Manage users
  - [psick::time](docs/time.md) - Manage time and timezones [Linux/Windows]
  - [psick::windows::](docs/windows.md) - Windows profiles and tools


### Applications profiles

For some applications, besides standard tp profiles, there are dedicated profile classes and defines. Here's a list:

  - [psick::ansible](docs/ansible.md) - Manage Ansible installation and user
  - [psick::aws](docs/aws.md) - Manage AWS client tools and infrastructures setup
  - [psick::bolt](docs/bolt.md) - Manage Bolt installation and user
  - [psick::docker](docs/docker.md) - Docker installation and build tools
  - [psick::foreman](docs/foreman.md) - Foreman installation
  - [psick::git](docs/git.md) - Git installation and configuration
  - [psick::gitlab](docs/gitlab.md) - GitLab installation and configuration
  - [psick::mariadb](docs/mysql.md) - Manage Mariadb
  - [psick::mysql](docs/mysql.md) - Manage Mysql
  - [psick::mongo](docs/mongo.md) - Manage Mongo
  - [psick::php](docs/php.md) - Manage php and modules
  - [psick::oracle](docs/oracle.md) - Manage Oracle prerequisites and installation
  - [psick::sensu](docs/sensu.md) - Manage Sensu
