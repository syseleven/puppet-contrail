class contrail::profile::discovery(
  $zk_server_ip = hiera('contrail::zk_server_ip'),
  $zk_server_port = hiera('contrail::zk_server_port'),
  $listen_ip_addr = hiera('contrail::discovery::listen_ip_addr', '0.0.0.0'),
  $listen_port = hiera('contrail::discovery::listen_port', '5998'),
  $log_local = hiera('contrail::discovery::log_local', 'True'),
  $log_file = hiera('contrail::discovery::log_file', '/var/log/contrail/discovery.log'),
  $log_level = hiera('contrail::discovery::log_level', 'SYS_DEBUG'),
  $reset_config = hiera('contrail::discovery::reset_config', 'True'),
  $control_service = hiera('contrail::discovery::control_service',true),
  $cassandra_server_list = $contrail::resources::params::cassandra_server_list
) inherits contrail::resources::params {
  include contrail::profile::packages::config
  include contrail::profile::discovery::monitoring

  $contrail_version = hiera('contrail::version', '1.06')

  if $contrail_version == '1.06' {
    $discovery_config_file = '/etc/contrail/discovery.conf'
  } else {
    $discovery_config_file = '/etc/contrail/contrail-discovery.conf'
  }

  file {$discovery_config_file:
    ensure  => file,
    mode    => '444',
    content => template("$module_name/contrail/discovery.conf.erb")
  }

  if $control_service {
    service { 'contrail-discovery':
      ensure => running,
      enable => true,
    }
  }

}
