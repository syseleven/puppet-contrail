define contrail::profile::redis::service(
  $instance_name = $title,
  $port,
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  include contrail::profile::redis::package

  file {"/etc/init/redis-server-${instance_name}.conf":
    ensure  => file,
    content => template("$module_name/init/redis-server.conf.erb"),
  } ~>

  file {"/etc/init.d/redis-server-${instance_name}":
    ensure => link,
    target => '/lib/init/upstart-job',
  } ->

  file {"/etc/redis/redis-${instance_name}.conf":
    ensure => file,
    source => "puppet:///modules/$module_name/redis/redis-${instance_name}.conf",
  } ~>

  service {"redis-server-${instance_name}":
    ensure  => running,
    enable  => true,
    require => File["/etc/init.d/redis-server-${instance_name}"],
  }

  case $monitoring {
    'sensu':  { 
      sensu::check{"redis-${instance_name}-$port":
        command => "/usr/lib/nagios/plugins/check_tcp  -H localhost -p $port",
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }

}

