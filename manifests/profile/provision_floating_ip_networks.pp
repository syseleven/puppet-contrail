class contrail::profile::provision_floating_ip_networks(
  $api_address = hiera('contrail::apiserver::address'),
  $floating_ip_networks = {},
) {

  file { '/usr/local/sbin/provision_floating_ip_network.py':
    ensure => file,
    mode   => '0555',
    source => "puppet:///modules/$module_name/provisioning/provision_floating_ip_network.py",
  }

  define provision_network(
    $floating_ip_networks,
    $api_address,
  ) {
    exec {"provision floating ip network $name":
      command   => ". /root/openrc; /usr/local/sbin/provision_floating_ip_network.py --ip_prefix ${floating_ip_networks[$name]['ip_prefix']} --ip_prefix_len ${floating_ip_networks[$name]['ip_prefix_len']} --gateway ${floating_ip_networks[$name]['gateway']} --route_target ${floating_ip_networks[$name]['route_target']} --net_name $name --api_address $api_address",
      provider  => 'shell',
      logoutput => true,
      unless    => ". /root/openrc && neutron net-show $name",
      require   => [File['/usr/local/sbin/provision_floating_ip_network.py'], Service['contrail-api']],
    }
  }

  if $floating_ip_networks {
    $floating_ip_networks_keys = keys($floating_ip_networks)
    provision_network { $floating_ip_networks_keys:
      floating_ip_networks => $floating_ip_networks,
      api_address          => $api_address,
    }
  }
}
