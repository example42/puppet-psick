class psick::docker::run_examples (
  Variant[Boolean,String] $ensure             = present,
  Enum['command','service'] $default_run_mode = command,
) {

  include ::psick::docker

  Psick::Docker::Run {
    ensure   => $ensure,
    require  => Class['psick::docker'],
    run_mode => $default_run_mode,
  }
  # Run, in command mode, a container based on official jenkins image
  ::psick::docker::run { 'jenkins':
    image       => 'jenkins',
    run_options => '-p 8080:8080 -p 50000:50000',
  }

  # Run a local image built with docker::push
#  ::psick::docker::run { 'puppet-agent': 
#  }
#  ::psick::docker::run { 'apache': 
#  }


  # Run, in service mode (an init file is created and a service started), an official redis instance
  ::psick::docker::run { 'redis':
    image          => 'redis',
    # run_mode     => 'service',
    container_name => 'official_redis',
  }

  ::psick::docker::run { 'registry':
    image          => 'registry',
    repository_tag => '2.4.0',
    run_options    => '-p 5000:5000',
  }

  ::psick::docker::run { 'admiral':
    image       => 'vmware/admiral',
    run_mode    => 'service',
    run_options => '-p 8282:8282',
  }

}
