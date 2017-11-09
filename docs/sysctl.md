## psick::sysctl - Manage sysctl settings

This class manages sysctl settings. To include it:

    psick::base::linux_classes:
      'sysctl': '::psick::sysctl'

Any sysctl setting can be set via Hiera, using the ```psick::sysctl::settings``` key, which expects an hash like:

    psick::sysctl::settings:
      kernel.shmmni: value: 4096
      kernel.sem: value: 250 32000 100 128

It's possible to specify which sysctl module to use, other than psick internal's default:

    psick::sysctl::module: 'duritong'

The specified module must be on your control-repo's Puppetfile. Not all modules are supported (it's easy to add new ones).

