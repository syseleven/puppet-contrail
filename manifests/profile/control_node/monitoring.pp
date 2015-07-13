class contrail::profile::control_node::monitoring (
  $monitoring = hiera('sys11stack::monitoring', false),
  $run_service = hiera('contrail::control_node::run_service', false),
  $controllers = hiera_hash('sys11stack::controllers', false),
) {

  $contrail_version = hiera('contrail::version', '1.06')

  if $contrail_version == '1.06' {
    $process_name = '-C control-server'
  } else {
    $process_name = '-a contrail-control'
  }

  case $monitoring {
    'sensu':  {
      if $run_service {
        sensu::check{'contrail-control-node-tcp':
          command => '/usr/lib/nagios/plugins/check_tcp -H localhost -p 8083',
        }

        sensu::check{'contrail-control-node-process':
          command => "/usr/lib/nagios/plugins/check_procs $process_name -c 1:1",
        }
      }

      if $controllers {
        $controller_ips = controllers2array($controllers, 'ips')
        $controller_ips_real = join($controller_ips, ' ')

        file {'/usr/lib/nagios/plugins/check_contrail_control_cluster':
          ensure => file,
          mode   => '0555',
          source => "puppet:///modules/$module_name/monitoring/check_contrail_control_cluster",
        }->
        sensu::check{'contrail-control-cluster':
          command => "/usr/lib/nagios/plugins/check_contrail_control_cluster $controller_ips_real",
        }
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}
