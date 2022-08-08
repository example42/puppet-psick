
## Main psick variables and common parameters

The main ```psick``` class manages classification (it includes ```psick::pre```, ```psick::base```, ```psick::profiles``` and eventually ```psick::firstrun``` classes, from where classes are included based on Hiera data) and exposes some parameters which can be used by other psick profiles.

#### Parameters in main psick class used by other psick profiles

Some of psick class' parameters are used as defaults for all tp profiles and most of the base ones.

They are as follows, with their default values.

Define if to actually manage any resource. This setting is the default entry point for the manage paramenter on each psick class.

    Boolean $manage            = true

If to manage automatically prerequisites for the used profiles. This affects tp::install and other resources.
Set to false, globally or in specific profiles, to cope with duplicated resources errors, in case same prerequisites are requested by more profiles.

    Boolean $auto_prereq       = true

If to use the noop() function for all the classes included in this module. This setting is the default for all the psick classes, and can be overridden in each of them. When true the value of the parameter noop_value is passed to the noop() function.

    Boolean $noop_manage       = false

The value to pass to the noop function when $noop_manage is true. This value is the default, which can be overridden, in each psick class.

    Boolean $noop_value        = false # No-noop is enforced on the class and overrides any noop settings
    Boolean $noop_value        = true  # Noop is enforced on the class

#### Special parameters in main psick class

A generic, by default empty, hash of custom settings to use as needed in any class included by psick.
No psick profile is using this.

    Hash $settings             = {}

An hash of different endpoints for different infrastructure services (which may be referenced in different classes).
Currently used in psick::proxy

    Hash $servers              = {}

An hash that configures the default resource defaults for tp::install, tp::conf and tp::dir defines.
Is honoured by the above tp defines in any class included via psick.

    Hash $tp                   = {} # Defaults in data/common.yaml

An hash to configure firewall related settings.

    Hash $firewall             = {} # Defaults in data/common.yaml

An hash to configure monitor related settings.

    Hash $monitor              = {} # Defaults in data/common.yaml

A parameter that disables forced ordering of the classes included in psick different phases (pre, base, profiles). Set this to false when you can dependency cicles between classes included via psick which you are not able to manage via proper psick classification. If set to false classes included in pre might not be actually applied before the other ones.

    Boolean $force_ordering    = true

#### Common parameters in psick base and tp profiles

Some other parameters can be found in psick profiles:

Generic hash of options which can be used in templates evaluated in the relevant profile. It's looked up in deep merge mode and in some profiles in can be merged with local default settings. In erb templates the keys used in the $options_hash can be generally referred with <%= @options['key'] %>, with the $options var being the merge of a local $options_default + $options_hash.

    Hash            $options_hash             = {}

If to install or remove the relevant profile resources (can be present, absent, installed or a version number):

    Psick::Ensure   $ensure                   = 'present'

What module to use to manage the relevant profile application. This is present is some base profiles. The default is to use local psick resources (usually a tp profile), some profiles have integrations with different common public modules.

    String          $module                  = 'psick'
