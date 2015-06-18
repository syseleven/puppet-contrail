class contrail::profile::schema_transformer::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  {
      # TODO implement check for active/backup
      # in backup mode schema will not listen on 8087
      #sensu::check{'contrail-schema-transformer-tcp':
      #    command => '/usr/lib/nagios/plugins/check_tcp  -H localhost -p 8087',
      #  }

      sensu::check{'contrail-schema-transformer-process':
        command => '/usr/lib/nagios/plugins/check_procs -C contrail-schema -c 1:1',
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
