class contrail::profile::analytics::query_engine(
  $disc_server_ip  = hiera('contrail::disc_server_ip'),
  $disc_server_port = hiera('contrail::disc_server_port', '5998'),
  $redis_server = hiera('contrail::analytics::query_engine::redis_ip'),
  $redis_port = hiera('contrail::analytics::query_engine::redis_port'),
  $log_file = hiera('contrail::analytics::query_engine::log_file', '/var/log/contrail/contrail-query-engine.log'),
  $log_level = hiera('contrail::analytics::query_engine::log_level', 'SYS_DEBUG'),
  $http_server_port = hiera('contrail::analytics::query_engine::http_server_port', '8091'),
  $cassandra_server_list = $contrail::resources::params::cassandra_server_list,
  $collectors = $contrail::resources::params::collectors,
) inherits contrail::resources::params {
  include contrail::profile::packages::analytics

  file {'/etc/contrail/contrail-query-engine.conf':
    ensure  => file,
    mode    => '444',
    content => template("$module_name/contrail/contrail-query-engine.conf.erb"),
  } ~>

  service {'contrail-query-engine':
    ensure => running,
    enable => true,
  }
}
