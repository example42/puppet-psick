## Configure proxy client

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

