
### tp profiles (DEPRECATED)

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
