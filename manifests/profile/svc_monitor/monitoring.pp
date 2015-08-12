class contrail::profile::svc_monitor::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  { 
      # TODO implement check for active/backup
      # in backup mode schema will not listen on 8087
      #sensu::check{'contrail-svc-monitor-tcp':
      #  command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 8088',
      #}

      sensu::check{'contrail-svc-monitor-process':
        command => '/usr/lib/nagios/plugins/check_procs -a contrail-svc-monitor -c 1:2',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
