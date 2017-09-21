# PSICK The Puppet Infrastructure module

This is the PSICK (Puppet Systems Infrastructure Construction Kit) module.

It contains an extendable set of profiles for common systems management activities and all the necessary data entry points to configure a whole infrastructure via Puppet.

It can be used as a strandalone module, just:

    include psick

and configure with Hiera yaml data like:
    
    ---
    # Pre and Base classes for Linux nodes
    psick::pre::linux_classes:
      hosts: '::psick::hosts::resource'
      users: '::psick::users::static'
      hostname: '::psick::hostname'
      dns: '::psick::dns::resolver'
      proxy: '::psick::proxy'
    psick::base::linux_classes:
      mail: '::psick::mail::postfix'
      ssh: '::psick::ssh::openssh'
      sudo: '::psick::sudo'
      logs: '::psick::logs::rsyslog'
      time: '::psick::time'
      sysctl: '::psick::sysctl'
      update: '::psick::update'
      motd: '::psick::motd'
      profile: '::psick::profile'
    
    # Pre and Base classes for Windows nodes
    psick::pre::windows_classes:
      hosts: '::psick::hosts::resource'
    psick::windows::base_classes:
      features: '::psick::windows::features'
      registry: '::psick::windows::registry'
      users: '::psick::users::ad'
      time: '::psick::time'
    
    # Repo settings
    psick::repo::add_defaults: true
    
    # Time settings
    psick::time::servers:
      - 'pool.ntp.org'
    
    # Timezone settings
    psick::timezone::timezone: 'UTC'
    
    # Sample sysctl settings
    psick::sysctl::settings:
      net.ipv4.conf.all.forwarding: 0

or within the PSICK [control-repo](https://github.com/example42/psick).

PSICK is entirely data driven configurable, for features which are not managed directly it leave entry points to include and manage any other resource.


## ::psick::proxy - Proxy Management

If your servers need a proxy to access the Internet you can include the ```psick::proxy``` class directly in your base classes:

    psick::base::linux_classes:
      proxy: '::psick::proxy'

and manage proxy settings with:

    psick::servers:
      proxy:
        host: proxy.example.com
        port: 3128
        user: john    # Optional
        password: xxx # Optional
        no_proxy:
          - localhost
          - "%{::domain}"
          - "%{::fqdn}"
        scheme: http

You can customise the components for which proxy should be configured, here are the default params:

    psick::proxy::ensure: present
    psick::proxy::configure_gem: true
    psick::proxy::configure_puppet_gem: true
    psick::proxy::configure_pip: true
    psick::proxy::configure_system: true
    psick::proxy::configure_repo: true


## ::psick::hosts::file - /etc/hosts management

This class manages /etc/hosts

To customise its behaviour you can set the template to use to manage ```/etc/hosts```, and the ipaddress, domain and hostname values for the local node (by default the relevant facts values are used):

    psick::hosts::file::template: 'psick/hosts/file/hosts.erb' # Default value
    psick::hosts::file::ipaddress: '10.0.0.4' # Default: $::ipaddress
    psick::hosts::file::domain: 'domain.com' # Default: $::domain
    psick::hosts::file::hostname: 'www01' # Default: $::hostname


## ::psick::update - Manage packages updates

This class manages how and when a system should be updated, it can be included with the parameter:

    psick::base::linux_classes:
      'update': '::psick::update'

The class just creates a cronjob which runs the system's specific update command. By default the cron schedule is empy so not update is automatically done:

    psick::update::cron_schedule: '0 6 * * *' 

The above setting would create a cron job, executed every day at 6:00 AM, that updates the system's packages.


## ::psick::sudo - Manage sudo

This class manages sudo. It can be included by setting:

    psick::base::linux_classes:
      'sudo': '::psick::sudo'

You can configure the template to use for ```/etc/sudoers```, the admins who can sudo on your system (if it's used the default or a compatible template), the Puppet fileserver source for the whole content of the ```/etc/sudoers.d/```:

    psick::sudo::sudoers_template: 'psick/sudo/sudoers.erb' # Default value
    psick::sudo::admins: # Default is [] 
      - al
      - mark
      - bill
    psick::sudo::sudoers_d_source: 'puppet:///modules/site/sudo/sudoers.d' # Default is empty

It's also possible to provide an hash of custom sudo directives to pass to the ```::tools::sudo::directive``` define:

    psick::sudo::directives:
      oracle:
        template: 'psick/sudo/oracle.erb'
        order: 30
       
The ```::tools::sudo::directive``` define accepts these params (template, content and source are ALTERNATIVE way to manage the content of the sudo file):

    define tools::sudo::directive (
      Enum['present','absent'] $ensure   = present,
      Variant[Undef,String]    $content  = undef,
      Variant[Undef,String]    $template = undef,
      Variant[Undef,String]    $source   = undef,
      Integer                  $order    = 20,
    ) { ...}


## ::psick::sysctl - Manage sysctl settings

This class manages sysctl settings. To include it:

    psick::base::linux_classes:
      'sysctl': '::psick::sysctl'

Any sysctl setting can be set via Hiera, using the ```psick::sysctl::settings``` key, which expects and hash (looked up via hiera_hash so values across the hierarchies are merged):

    psick::sysctl::settings:
      kernel.shmmni:
        value: 4096
      kernel.sem:
        value: 250 32000 100 128


## ::psick::motd - Manage /etc/motd and /etc/issue files

This class just manages the content of the ```/etc/motd.conf``` and ```/etc/issue``` files. To include it:

    profile::base::linux::motd_class: '::psick::motd'

To customise the content of the provided files:

    psick::motd::motd_file_template: 'psick/motd/motd.erb' # Default value
    psick::motd::issue_file_template: 'psick/motd/issue.erb' # Default value

To avoid to manage these files:

    psick::motd::motd_file_template: ''
    psick::motd::issue_file_template: ''

To remove these files:

    psick::motd::motd_file_ensure: 'absent'
    psick::motd::issue_file_ensure: 'absent'


# Other profiles

## ::psick::oracle - Manages prerequisites and installation

This psick should be added to oracle servers. By default it does nothing, but, activating the relevant parameters, it allows
the configuration of all the prerequisites for Oracle 12 installation and, if installation files are available, it can automate the installation of Oracle products (via the biemond/oradb external module).

Main use case is the configuration for prerequisites. This can be done with:

    profiles:
      psick::oracle

    # Activate the prerequisites class that manages /etc/limits
    psick::oracle::prerequisites::limits_class: 'psick::oracle::prerequisites::limits'

    # Activate the prerequisites class that manages packages
    psick::oracle::prerequisites::packages_class: 'psick::oracle::prerequisites::packages'


    # Activate the prerequisites class that manages users
    psick::oracle::prerequisites::users_class: 'psick::oracle::prerequisites::users'
    psick::oracle::prerequisites::users::has_asm: true # Set this on servers with asm

    # Activate the prerequisites class that manages sysctl
    psick::oracle::prerequisites::sysctl_class: 'psick::oracle::prerequisites::sysctl'
    profile::base::linux::sysctl_class: '' # The base default sysctl class conflicts with the above

    # Activate the prerequisites class that cretaes a swap file (needs petems/swap_file module)
    # psick::oracle::prerequisites::swap_class: 'psick::oracle::prerequisites::swap'

    # Activate the dirs class and create a set of dirs for Oracle data
    psick::oracle::prerequisites::dirs_class: 'psick::oracle::prerequisites::dirs'
    psick::oracle::prerequisites::dirs::base_dir: '/data/oracle' # Default value
    psick::oracle::prerequisites::dirs::owner: 'oracle'          # Default value
    psick::oracle::prerequisites::dirs::group: 'dba'             # Default value
    psick::oracle::prerequisites::dirs::dirs:
     app1:
       - 'db1'
       - 'db2'
     app2:
       - 'db1'
   psick::oracle::prerequisites::dirs::suffixes:   # Default value is ''
     - '_DATA'
     - '_FRA'

with the above settings the following directories are created:

    /data/oracle/app1_DATA/db1
    /data/oracle/app1_DATA/db2
    /data/oracle/app1_FRA/db1
    /data/oracle/app1_FRA/db2
    /data/oracle/app2_DATA/db1
    /data/oracle/app2_FRA/db1


