## /etc/hosts management

psick::hosts::file class manages /etc/hosts

To customise its behaviour you can set the template to use to manage ```/etc/hosts```, and the ipaddress, domain and hostname values for the local node (by default the relevant facts values are used):

    psick::hosts::file::template: 'psick/hosts/file/hosts.erb' # Default value
    psick::hosts::file::ipaddress: '10.0.0.4' # Default: $::ipaddress
    psick::hosts::file::domain: 'domain.com' # Default: $::domain
    psick::hosts::file::hostname: 'www01' # Default: $::hostname


