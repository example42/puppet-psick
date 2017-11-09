## psick::sudo - Manage sudo

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

It's also possible to provide an hash of custom sudo directives to pass to the ```::psick::sudo::directive``` define:

    psick::sudo::directives:
      oracle:
        template: 'psick/sudo/oracle.erb'
        order: 30
       
The ```::psick::sudo::directive``` define accepts these params (template, content and source are ALTERNATIVE way to manage the content of the sudo file):

    define psick::sudo::directive (
      Enum['present','absent'] $ensure   = present,
      Variant[Undef,String]    $content  = undef,
      Variant[Undef,String]    $template = undef,
      Variant[Undef,String]    $source   = undef,
      Integer                  $order    = 20,
    ) { ...}


