class contrail::profile::analytics::analytics_api(
  $disc_server_ip  = hiera('contrail::disc_server_ip'),
  $disc_server_port = hiera('contrail::disc_server_port', '5998'),

  $log_file = hiera('contrail::analytics::query_engine::log_file', '/var/log/contrail/contrail-analytics-api.log'),
  $log_level = hiera('contrail::analytics::query_engine::log_level', 'SYS_DEBUG'),

  $redis_server = hiera('contrail::analytics::query_engine::redis_ip'),
  $redis_collector_port = hiera('contrail::analytics::collector::redis_port'),
  $redis_query_port = hiera('contrail::analytics::query_engine::redis_port'),
  $rest_api_ip = hiera('contrail::analytics::analytics_api::listen_ip', '0.0.0.0'),
  $rest_api_port = hiera('contrail::analytics::analytics_api::listen_port', '8081'),
  $host_ip = hiera('contrail::analytics::analytics_api::host_ip'),
  $cassandra_server_list = $contrail::resources::params::cassandra_server_list,
  $collectors = $contrail::resources::params::collectors,
) inherits contrail::resources::params {
  include contrail::profile::packages::analytics
  include contrail::profile::analytics::analytics_api::monitoring

  file {'/etc/contrail/contrail-analytics-api.conf':
    ensure  => file,
    mode    => '444',
    content => template("$module_name/contrail/contrail-analytics-api.conf.erb"),
  } ~>

  service {'contrail-analytics-api':
    ensure => running,
    enable => true,
  }
}
