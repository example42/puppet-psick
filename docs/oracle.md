## How to manage Oracle prerequisites and installation

This psick profile should be added to oracle servers. By default it does nothing, but, activating the relevant parameters, it allows
the configuration of all the prerequisites for Oracle 12 installation and, if installation files are available, it can automate the installation of Oracle products (via the biemond/oradb external module).

Main use case is the configuration for prerequisites. This can be done with:

    psick::profiles::linux_classes:
      'oracle': psick::oracle

    # Activate the prerequisites class that manages /etc/limits
    psick::oracle::prerequisites::limits_class: 'psick::oracle::prerequisites::limits'

    # Activate the prerequisites class that manages packages
    psick::oracle::prerequisites::packages_class: 'psick::oracle::prerequisites::packages'


    # Activate the prerequisites class that manages users
    psick::oracle::prerequisites::users_class: 'psick::oracle::prerequisites::users'
    psick::oracle::prerequisites::users::has_asm: true # Set this on servers with asm

    # Activate the prerequisites class that manages sysctl
    psick::oracle::prerequisites::sysctl_class: 'psick::oracle::prerequisites::sysctl'
    psick::base::linux_classes:
      'sysctl': '::psick::sysctl' # The base default sysctl class conflicts with the above

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


