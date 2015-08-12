class contrail::profile::svc_monitor(
  $api_server_ip = hiera('contrail::apiserver::address'),
  $api_server_port = hiera('contrail::apiserver::port', '8082'),
  $ifmap_server_ip = hiera('contrail::ifmap_server_ip'),
  $ifmap_server_port = hiera('contrail::ifmap_server_port', '8443'),
  $ifmap_username  = hiera('contrail::svc_monitor::ifmap_username'),
  $ifmap_password  = hiera('contrail::svc_monitor::ifmap_password'),
  $zk_server_port  = hiera('contrail::zk_server_port'),
  $zk_server_ip = $contrail::resources::params::zk_hosts,
  $disc_server_ip  = hiera('contrail::disc_server_ip'),
  $disc_server_port = hiera('contrail::disc_server_port', '5998'),
  $region_name = hiera('contrail::svc_monitor::region_name', 'None'),
  $log_file = hiera('contrail::svc_monitor::log_file', '/var/log/contrail/svc-monitor.log'),

  $keystone_auth_host = hiera('contrail::keystone_auth_host'),
  $keystone_auth_port = hiera('contrail::keystone_auth_port', '35357'),
  $keystone_auth_protocol = hiera('contrail::keystone_auth_protocol', 'http'),
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),

  $rest_api_ip = hiera('contrail::analytics::analytics_api::ip', '0.0.0.0'),
  $rest_api_port = hiera('contrail::analytics::analytics_api::port', '8081'),
  $cassandra_server_list = $contrail::resources::params::cassandra_server_list,
  $rabbit_server  = hiera('contrail::rabbit_server'),
  $rabbit_user  = hiera('contrail::rabbit_user'),
  $rabbit_password  = hiera('contrail::rabbit_password'),
  $rabbit_port = hiera('contrail::rabbit_port'),
) inherits contrail::resources::params {
  include contrail::profile::packages::config_openstack
  include contrail::profile::svc_monitor::monitoring

  file {'/etc/contrail/svc-monitor.conf':
    ensure  => file,
    owner   => 'contrail',
    group   => 'contrail',
    mode    => '0440',
    content => template("$module_name/contrail/svc-monitor.conf.erb"),
    notify  => Service['contrail-svc-monitor'],
    require => Package['contrail-config'],
  } ~>

  # file ships with package and confuses people
  file { '/etc/contrail/contrail-svc-monitor.conf':
    ensure => absent,
  }

  service {'contrail-svc-monitor':
    ensure => running,
    enable => true,
  }
}
