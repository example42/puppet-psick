# PSICK: The Infrastructure Puppet module

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/217fe49678574788b28ef3fc71c6fa47)](https://www.codacy.com/gh/example42/puppet-psick/dashboard?utm_source=github.com&utm_medium=referral&utm_content=example42/puppet-psick&utm_campaign=Badge_Grade)

This is the PSICK (Puppet Systems Infrastructure Construction Kit) module.

An **Infrastructure module** to manage most of what you need to manage with Puppet.

The psick module provides the following features:

-   [Classification](docs/classification.md) - Option to manage Puppet classification in a smart Hiera driven way.
-   A set of [base profiles](docs/profiles.md) for common systems management task on common os: Linux, MacOS, Windows. 
-   Integration with the companion **psick_profile** module to manage multiple applications

The module is designed to:

-   Permit quick, safe and easy integration in any Puppet setup
-   Allow cherry picking of the desired functionalities and profiles
-   Be entirely Hiera driven: In practice a DSL to configure infrastructures

It can be used together with the [PSICK control-repo](https://github.com/example42/psick) or as a strandalone module, just:

    include psick

This doesn't do anything at all, by default, but is enough to let you manage _everything_ via Hiera.

In the following examples we will use Hiera YAML files, but any backend can be used: psick is a normal, even if somehow unusual, Puppet module, with classes (a lot of them) whose params can be set as Hiera data, defines, templates, files, fuctions, custom data types etc.

Check the default [PSICK hiera data](https://github.com/example42/psick-hieradata) module for various usage examples.

## Do You Speak Psick?

Psick "language" has the syntax of any Hiera supported backend (here we use YAML), and the semantic you are going to discover here.

The module provides 3 major features:

-   Structured cross-os, staged **classification**
-   Base **profiles** for common system configurations
-   Integration with **psick_profile** to manage applications

### Classification

Psick can manage the whole classification of the nodes of an infrastructure. It can work side by side and External Node Classifier, or it can totally replace it.

When used for classification, you just need to include the psick class on all your nodes and then configure it via Hiera, considering that:

-   Different Hiera keys are available to manage the classes to include for different OSes ans different stages of the classification
-   Psick has 4 classification stages, by default they require the previous one to be completed: First run (optional), pre, main and profile.
-   Each Hiera key used to classify, has as value an hash of key values, where keys are strings used as placeholders, and values are the classes to include.

Example of Hiera data to classifiy Linux and Windows nodes:

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
      mail: psick_profile::postfix
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
      webserver: psick_profile::iis

### Psick base profiles

Psick provides ready to use profiles for many common OS configurations: users management, time, openssh, keys, cronjobs, sysctl, different languages setups (php, ruby, python...), motd, hosts file, common packages, proxy... 

Refer to the specific documentation for more details. Here is some example Hiera data to manage uan user with admin powers, the dns resolver and some limits, according to the profile used:

    # User al creation with ssh_authorized_keys:
    psick::users::users_hash:
      al:
        ensure: present
        comment: 'Al'
        groups:
          - users
          - wheel
        ssh_authorized_keys:
          - 'ssh-rsa AAAAB3NzaC...'
    # Passwordless sudopowers for user al
    psick::sudo::directives:
      al:
        content: 'al ALL=(ALL) NOPASSWD:ALL'

    # Example to manage resolver
    psick::dns::resolver::nameservers:
      - 8.8.8.8
      - 1.1.1.1

    # Sample Limits
    psick::limits::limits_hash:
      '*/nofile':
        soft: 2048
        hard: 4096

### psick_profile and applications profiles

For some very common applications and languages, there are dedicated profile classes and defines, in the psick and the psick_profile modules. Here's a list from psick:

-   [psick::aws](docs/aws.md) - Manage AWS client tools and infrastructures setup
-   [psick::bolt](docs/bolt.md) - Manage Bolt installation and user
-   [psick::git](docs/git.md) - Git installation and configuration
-   [psick::php](docs/php.md) - Manage php and modules

And som from **psick_profile** module check it for details.

-   [psick_profile::docker](docs/docker.md) - Docker installation and build tools
-   [psick_profile::foreman::tp](docs/foreman.md) - Foreman installation
-   [psick_profile::ansible](docs/ansible.md) - Manage Ansible installation and user
-   [psick_profile::gitlab](docs/gitlab.md) - GitLab installation and configuration
-   [psick_profile::mariadb](docs/mysql.md) - Manage Mariadb
-   [psick_profile::mysql](docs/mysql.md) - Manage Mysql
-   [psick_profile::mongo](docs/mongo.md) - Manage Mongo
-   [psick_profile::oracle](docs/oracle.md) - Manage Oracle prerequisites and installation
-   [psick_profile::sensu](docs/sensu.md) - Manage Sensu

### Main variables and common parameters

The main psick class has some parameters which are used as defaults in all the psick and psick profile classes or can contain data (in Hashes of key-values) used by all the other psick profiless

You can use them as general switches or data sources which apply to psick and psick_profile classes.

Check for more details on the [Main Parameters](docs/main_parameters.md), here they are wit the default values:

    # General psick switches
    psick::manage: true
    psick::auto_prereq: true
    psick::noop_manage: false
    psick::noop_value: false
    psick::force_ordering: true

    # Available data general enpoints
    psick::settings: {}
    psick::servers: {}
    psick::tp: {}
    psick::firewall: {}
    psick::monitor: {}
