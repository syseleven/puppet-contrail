class contrail::profile::provision_vrouter(
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),
  $action = false,
) {
  if $action == 'export' {
    @@exec {"provision_vrouter $::hostname":
      command => "/usr/sbin/contrail-provision-vrouter --host_name $::hostname --host_ip $::ipaddress_vhost0 --admin_user $keystone_admin_user --admin_password $keystone_admin_password --admin_tenant_name $keystone_admin_tenant_name --oper add",
      tag  => 'provision_vrouter',
      # FIXME implement unless parameter
    }
  } elsif $action == 'import' {
    Exec <<| tag == "provision_vrouter" |>>
  }
}

