class contrail::profile::analytics::collector(

  $cassandra_server_list  = hiera('contrail::cassandra_server_list'),
  $disc_server_ip  = hiera('contrail::disc_server_ip'),
  $disc_server_port = hiera('contrail::disc_server_port', '5998'),
  $log_file = hiera('contrail::analytics::query_engine::log_file', '/var/log/contrail/contrail-collector.log'),
  $log_level = hiera('contrail::analytics::query_engine::log_level', 'SYS_DEBUG'),

  # Broken in Contrail collector, but here for reference purposes
  $collector_listen_ip = hiera('contrail::analytics::collector::address'),
  $collector_listen_port = hiera('contrail::analytics::collector::port'),

  $redis_server = hiera('contrail::analytics::collector::redis_ip'),
  $redis_port = hiera('contrail::analytics::collector::redis_port'),

) {
  include contrail::profile::packages::analytics
  include contrail::profile::analytics::collector::monitoring

  file {'/etc/contrail/contrail-collector.conf':
    ensure  => file,
    mode    => '444',
    content => template("$module_name/contrail/contrail-collector.conf.erb"),
  } ~>

  service {'contrail-collector':
    ensure => running,
    enable => true,
  }
}
