class contrail::profile::analytics::query_engine(

  $cassandra_server_list  = hiera('contrail::cassandra_server_list'),
  $disc_server_ip  = hiera('contrail::disc_server_ip'),
  $disc_server_port = hiera('contrail::disc_server_port', '5998'),
  $collectors_ip = hiera('contrail::analytics::collectors::address'),
  $collectors_port = hiera('contrail::analytics::collectors::port'),
  $redis_server = hiera('contrail::analytics::query_engine::redis_ip'),
  $redis_port = hiera('contrail::analytics::query_engine::redis_port'),
  $log_file = hiera('contrail::analytics::query_engine::log_file', '/var/log/contrail/contrail-query-engine.log'),
  $log_level = hiera('contrail::analytics::query_engine::log_level', 'SYS_DEBUG'),
  $http_server_port = hiera('contrail::analytics::query_engine::http_server_port', '8091'),

  

) {
  include contrail::profile::packages::analytics

  $collectors = "${collectors_ip}:${collectors_port}"

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
