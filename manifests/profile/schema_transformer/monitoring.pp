class contrail::profile::schema_transformer::monitoring (
  $controllers = hiera_hash('sys11stack::controllers', false),
  $monitoring = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  {
      sensu::check{'contrail-schema-transformer-process':
        command => '/usr/lib/nagios/plugins/check_procs -C contrail-schema -c 1:1',
      }

      if $controllers {
        $controller_ips = controllers2array($controllers, 'ips')
        $controller_ips_real = join($controller_ips, ' ')

        file {'/usr/lib/nagios/plugins/check_schema_transformer_leader':
          ensure => file,
          mode   => '0555',
          source => "puppet:///modules/$module_name/monitoring/check_schema_transformer_leader",
        }->
        sensu::check{'schema_transformer_leader':
          command => "/usr/lib/nagios/plugins/check_schema_transformer_leader $controller_ips_real",
        }
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
