class contrail::profile::discovery::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-discovery-server-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 5998',
      }

      sensu::check{'contrail-discovery-server-process':
        command => '/usr/lib/nagios/plugins/check_procs -a discovery-server -c 1:2',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
