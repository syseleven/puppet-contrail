class contrail::profile::analytics::analytics_api::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-analytics-api-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 8081',
      }

      sensu::check{'contrail-analytics-api-process':
        command => '/usr/lib/nagios/plugins/check_procs -a contrail-analytics-api -c 1:2',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
