class contrail::profile::ifmapserver::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-ifmap-server-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 8443',
      }

      sensu::check{'contrail-ifmap-server-process':
        command => '/usr/lib/nagios/plugins/check_procs -C ifmap-server -c 1:1',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
