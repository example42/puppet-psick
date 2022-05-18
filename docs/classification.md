## Classification with psick

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
