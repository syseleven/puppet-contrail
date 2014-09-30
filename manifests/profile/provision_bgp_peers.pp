class contrail::profile::provision_bgp_peers(
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),
  $api_address = hiera('contrail::apiserver::address'),
  $control_node_address = hiera('contrail::control_node::address'),
  $router_name = hiera('contrail::mx::router_name', false),
  $router_ip = hiera('contrail::mx::router_ip', false),
  $router_asn = hiera('contrail::mx::router_asn', false),
) {

  if $router_name {
    exec {"provision controller":
     command => "/usr/sbin/contrail-provision-control --host_ip $control_node_address --api_server_ip $api_address --oper add --admin_user $keystone_admin_user --admin_password $keystone_admin_password --host_name $::hostname --admin_tenant $keystone_admin_tenant_name", 
    } ->
    exec {"provision mx":
     command => "/usr/sbin/contrail-provision-mx --router_name $router_name --router_ip $router_ip --router_asn $router_asn --api_server_ip $api_address --oper add --admin_user $keystone_admin_user --admin_password $keystone_admin_password --admin_tenant $keystone_admin_tenant_name",
    }
  }
}

