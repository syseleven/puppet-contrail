class contrail::profile::provision_bgp_peers(
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),
  $api_address = hiera('contrail::apiserver::address'),
  $host_ip = hiera('sys11stack::bind_address'),
  $routers = hiera('contrail::routers', false),
  $router_asn = hiera('contrail::router_asn')
) {

  if $router_asn {
    exec { 'provision contrail controller':
      command => "/usr/sbin/contrail-provision-control --host_ip $host_ip --api_server_ip $api_address --router_asn $router_asn --oper add --admin_user $keystone_admin_user --admin_password $keystone_admin_password --host_name $::hostname --admin_tenant $keystone_admin_tenant_name --api_server_port 8082",
    }
  }


  define set_router(
    $routers,
    $keystone_admin_user,
    $keystone_admin_password,
    $keystone_admin_tenant_name,
    $api_address,
  ) {
    exec {"provision mx $name":
      command => "/usr/sbin/contrail-provision-mx --router_name $name --router_ip ${routers[$name]['router_ip']} --router_asn ${routers[$name]['router_asn']} --api_server_ip $api_address --oper add --admin_user $keystone_admin_user --admin_password $keystone_admin_password --admin_tenant $keystone_admin_tenant_name",
    }
  }

  if $routers {
    $router_keys = keys($routers)
    set_router { $router_keys:
      routers                    => $routers,
      keystone_admin_user        => $keystone_admin_user,
      keystone_admin_password    => $keystone_admin_password,
      keystone_admin_tenant_name => $keystone_admin_tenant_name,
      api_address                => $api_address
    }
  }
}

