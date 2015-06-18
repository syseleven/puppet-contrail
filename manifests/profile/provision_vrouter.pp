class contrail::profile::provision_vrouter(
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),
  $api_server_ip = hiera('contrail::apiserver::address','0.0.0.0'),
  $action = false,
) {
  if $action == 'export' {
    if $::ipaddress_vhost0 {
      @@exec {"provision_vrouter $::hostname":
        command => "/usr/sbin/contrail-provision-vrouter --host_name $::hostname --host_ip $::ipaddress_vhost0 --api_server_ip $api_server_ip --admin_user $keystone_admin_user --admin_password $keystone_admin_password --admin_tenant_name $keystone_admin_tenant_name --oper add",
        tag     => 'provision_vrouter',
        # FIXME implement unless parameter
      }
    }
  } elsif $action == 'import' {
    Exec <<| tag == "provision_vrouter" |>>
  }
}

