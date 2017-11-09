## psick::motd - Manage /etc/motd and /etc/issue files

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

