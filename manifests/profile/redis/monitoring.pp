define contrail::profile::redis::monitoring(
  $instance_name = $title,
  $port,
  $monitoring       = hiera('sys11stack::monitoring', false),
) {

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
