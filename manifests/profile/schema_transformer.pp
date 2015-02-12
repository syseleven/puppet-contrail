class contrail::profile::schema_transformer(
  $api_server = hiera('contrail::apiserver::address'),
  $base_url = hiera('contrail::schema_transformer::base_url', '/'),
  $api_port = hiera('contrail::apiserver::listen_port', '8082'),
  $cassandra_server_list  = hiera('contrail::cassandra_server_list'),

  $log_file = hiera('contrail::schema_transformer::log_file', '/var/log/contrail/contrail-schema.log'),
  $zk_server_ip  = hiera('contrail::zk_server_ip'),
  $zk_server_port  = hiera('contrail::zk_server_port'),
  $disc_server_ip  = hiera('contrail::disc_server_ip'),
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),

  $auth  = hiera('contrail::auth', 'keystone'),
  $keystone_auth_host = hiera('contrail::keystone_auth_host'),
  $keystone_auth_port = hiera('contrail::keystone_auth_port', '35357'),
  $keystone_auth_protocol = hiera('contrail::keystone_auth_protocol', 'http'),
  $keystone_base_url = hiera('contrail::keystone::base_url', '/v2.0/tokens'),
) {
  include contrail::profile::packages::config
  include contrail::profile::schema_transformer::monitoring

  file {'/etc/contrail/contrail-schema.conf':
    ensure  => file,
    owner   => 'contrail',
    group   => 'contrail',
    mode    => '0440',
    content => template("$module_name/contrail/contrail-schema.conf.erb"),
    notify  => Service['contrail-schema'],
  }

  file {'/etc/contrail/vnc_api_lib.ini':
    ensure  => file,
    owner   => 'contrail',
    group   => 'contrail',
    mode    => '0440',
    content => template("$module_name/contrail/vnc_api_lib.ini.erb"),
    notify  => Service['contrail-schema'],
  }

  service {'contrail-schema':
    ensure => running,
    enable => true,
  }
}
