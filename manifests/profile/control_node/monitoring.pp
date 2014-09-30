class contrail::profile::control_node::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-control-node-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp -H localhost -p 8083',
      }

      sensu::check{'contrail-control-node-process':
        command => '/usr/lib/nagios/plugins/check_procs -C control-node -c 1:1',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
