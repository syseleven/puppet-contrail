class contrail::profile::discovery::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {

  $contrail_version = hiera('contrail::version', '1.06')

  if $contrail_version == '1.06' {
    $process_name = "-C discovery-server"
  } else {
    $process_name = "-a contrail-discovery"
  }

  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-discovery-server-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 5998',
      }

      sensu::check{'contrail-discovery-server-process':
        command => "/usr/lib/nagios/plugins/check_procs $process_name -c 1:2",
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
