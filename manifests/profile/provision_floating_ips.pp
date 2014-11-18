class contrail::profile::provision_floating_ips(
  $action,
) {
  require contrail::profile::utils

  # create network needs to be done on controller
  if $action == 'create_network' {
    neutron_network { 'public':
      ensure          => present,
      router_external => 'True',
      tenant_name     => 'admin',
    }

    neutron_subnet { 'public':
      ensure       => 'present',
      cidr         => '192.168.254.0/24',
      network_name => 'public',
      tenant_name  => 'admin',
    }

    neutron_network { 'private':
      ensure      => present,
      tenant_name => 'admin',
    }
    neutron_subnet { 'private':
      ensure       => present,
      cidr         => '10.0.0.0/24',
      network_name => 'private',
      tenant_name  => 'admin',
    }
    neutron_router { 'admin_router':
      ensure               => present,
      tenant_name          => 'admin',
      gateway_network_name => 'public',
      require              => Neutron_subnet['public'],
    }

    neutron_router_interface { 'admin_router:private':
        ensure => present,
    }
  # network device must be create on compute node
  } elsif $action == 'create_vgw_device' {
    exec {'provision simple gateway SNAT':
      command     => 'python /usr/share/contrail-utils/provision_vgw_interface.py --oper create --interface vgw1 --subnets 10.0.0.0/24 --vrf default-domain:admin:private:private --routes 0.0.0.0/0',
      environment => ['PYTHONPATH=/usr/lib/python2.7/dist-packages/nova_contrail_vif/gen_py/instance_service'],
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      unless      => 'ifconfig vgw1',
    }
    exec {'provision simple gateway floating IPs':
      command     => 'python /usr/share/contrail-utils/provision_vgw_interface.py --oper create --interface vgw2 --subnets 192.168.254.0/24 --vrf default-domain:admin:public:public --routes 0.0.0.0/0',
      environment => ['PYTHONPATH=/usr/lib/python2.7/dist-packages/nova_contrail_vif/gen_py/instance_service'],
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      unless      => 'ifconfig vgw2',
    }

  }
}
