class contrail::profile::discovery(
  $zk_server_ip = hiera('contrail::zk_server_ip'),
  $zk_server_port = hiera('contrail::zk_server_port'),
  $listen_ip_addr = hiera('contrail::discovery::listen_ip_addr', '0.0.0.0'),
  $listen_port = hiera('contrail::discovery::listen_port', '5998'),
  $log_local = hiera('contrail::discovery::log_local', 'True'),
  $log_file = hiera('contrail::discovery::log_file', '/var/log/contrail/discovery.log'),
  $log_level = hiera('contrail::discovery::log_level', 'SYS_DEBUG'),
  $reset_config = hiera('contrail::discovery::reset_config', 'True'),
  $cassandra_server_list  = hiera('contrail::cassandra_server_list'),
) {
  include contrail::profile::packages::config
  include contrail::profile::discovery::monitoring

  file {'/etc/contrail/discovery.conf':
    ensure  => file,
    mode    => '444',
    content => template("$module_name/contrail/discovery.conf.erb")
  } ~>

  service {'contrail-discovery':
    ensure => running,
    enable => true,
  }
}
