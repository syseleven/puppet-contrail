class contrail::profile::apiserver::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-api-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 8082',
      }

      sensu::check{'contrail-api-process':
        command => '/usr/lib/nagios/plugins/check_procs -C contrail-api -c 1:1',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
