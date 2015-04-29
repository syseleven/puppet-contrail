class contrail::profile::analytics::analytics_api(
  $cassandra_server_list  = hiera('contrail::cassandra_server_list'),
  $disc_server_ip  = hiera('contrail::disc_server_ip'),
  $disc_server_port = hiera('contrail::disc_server_port', '5998'),
  $collectors = hiera('contrail::analytics::collectors'),

  $log_file = hiera('contrail::analytics::query_engine::log_file', '/var/log/contrail/contrail-analytics-api.log'),
  $log_level = hiera('contrail::analytics::query_engine::log_level', 'SYS_DEBUG'),

  $redis_server = hiera('contrail::analytics::query_engine::redis_ip'),
  $redis_collector_port = hiera('contrail::analytics::collector::redis_port'),
  $redis_query_port = hiera('contrail::analytics::query_engine::redis_port'),
  $rest_api_ip = hiera('contrail::analytics::analytics_api::listen_ip', '0.0.0.0')

) {
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
