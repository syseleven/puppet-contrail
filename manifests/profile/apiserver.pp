class contrail::profile::apiserver(
  $ifmap_server_ip = hiera('contrail::ifmap_server_ip'),
  $ifmap_server_port = hiera('contrail::ifmap_server_port', '8443'),
  $ifmap_username  = hiera('contrail::ifmap_username'),
  $ifmap_password  = hiera('contrail::ifmap_password'),
  $cassandra_server_list  = hiera('contrail::cassandra_server_list'),
  $listen_ip_addr = hiera('contrail::apiserver::listen_ip_addr', '0.0.0.0'),
  $listen_port = hiera('contrail::apiserver::listen_port', '8082'),
  $auth  = hiera('contrail::auth', 'keystone'),
  $multi_tenancy  = hiera('contrail::multi_tenancy', 'True'),
  $disc_server_ip  = hiera('contrail::disc_server_ip'),
  $disc_server_port = hiera('contrail::disc_server_port', '5998'),
  $zk_server_port  = hiera('contrail::zk_server_port'),
  $zk_server_ip_configured  = hiera('contrail::zk_server_ip'),
  $rabbit_server  = hiera('contrail::rabbit_server'),
  $rabbit_user  = hiera('contrail::rabbit_user'),
  $rabbit_password  = hiera('contrail::rabbit_password'),

  $keystone_auth_host = hiera('contrail::keystone_auth_host'),
  $keystone_auth_port = hiera('contrail::keystone_auth_port', '35357'),
  $keystone_auth_protocol = hiera('contrail::keystone_auth_protocol', 'http'),
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),

) {
  include contrail::profile::packages::config
  include contrail::profile::apiserver::monitoring

  $zk_server_ip = "${zk_server_ip_configured}:${zk_server_port}"

  file {'/etc/contrail/contrail-api.conf':
    ensure  => file,
    owner   => 'contrail',
    group   => 'contrail',
    mode    => '0440',
    content => template("$module_name/contrail/contrail-api.conf.erb"),
    notify  => Service['contrail-api'],
  } ~>

  service {'contrail-api':
    ensure => running,
    enable => true,
  }
}
