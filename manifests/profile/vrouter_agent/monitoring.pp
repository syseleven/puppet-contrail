class contrail::profile::vrouter_agent::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {

  $contrail_version = hiera('contrail::version', '1.06')

  if $contrail_version == '1.06' {
    $process_name = "vnswad"
  } else {
    $process_name = "contrail-vrouter-agent"
  }

  case $monitoring {
    'sensu':  { 
      sensu::check{'contrail-vrouter-agent-tcp':
        command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 8085',
      }

      sensu::check{'contrail-vrouter-agent-process':
        command => "/usr/lib/nagios/plugins/check_procs -C $process_name -c 1:1",
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
