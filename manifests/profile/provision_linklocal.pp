# Class ...
# this class provisions metadata linklocal services
#
class contrail::profile::provision_linklocal(
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),
  $nova_api_address = hiera('contrail::nova::api_address'),
) {
  exec {"provision linklocal":
   command => "/usr/sbin/contrail-provision-linklocal --admin_user $keystone_admin_user --admin_password $keystone_admin_password --linklocal_service_name metadata --linklocal_service_ip 169.254.169.254 --linklocal_service_port 80 --ipfabric_service_ip $nova_api_address --ipfabric_service_port 8775"
  }
}

