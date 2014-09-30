class contrail::profile::zookeeper::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      sensu::check{'zookeeper-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 2181',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
