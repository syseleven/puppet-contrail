class contrail::profile::analytics::collector::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-collector-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 8086',
      }

      sensu::check{'contrail-collector-process':
        command => '/usr/lib/nagios/plugins/check_procs -a contrail-collector -c 1:2',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
