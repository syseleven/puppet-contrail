class contrail::profile::neutron::server(
  $multi_tenancy  = hiera('contrail::multi_tenancy', 'True'),
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),
  $keystone_auth_url = hiera('sys11stack::keystone_auth_url'),
  $version = hiera('contrail::package_version', 'installed'),
  $api_server_ip = hiera('sys11stack::profile::pacemaker::vip'),
) {
  # TODO neutron.conf currently solved in sys11stack::profile::neutron/common.pp

  package {'neutron-plugin-contrail':
    ensure => $version,
    #before => Class['sys11stack::profile::neutron::common'],
  } ->

  file {'/etc/neutron/plugins/opencontrail/ContrailPlugin.ini':
    ensure  => file,
    mode    => '444',
    content => template("$module_name/neutron/ContrailPlugin.ini.erb"),
    notify  => Service['neutron-server'],
  }
}
