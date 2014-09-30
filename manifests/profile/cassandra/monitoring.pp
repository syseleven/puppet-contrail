class contrail::profile::cassandra::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      sensu::check{'cassandra-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 7199',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
