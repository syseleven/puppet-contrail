class contrail::profile::control_node::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {

  $contrail_version = hiera('contrail::version', '1.06')

  if $contrail_version == '1.06' {
    $process_name = "control-server"
  } else {
    $process_name = "contrail-control"
  }

  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-control-node-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp -H localhost -p 8083',
      }

      sensu::check{'contrail-control-node-process':
        command => "/usr/lib/nagios/plugins/check_procs -C $process_name -c 1:1",
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
