class contrail::role::controller() {

  require contrail::profile::opencontrailppa

  class {'contrail::profile::lib':}
  class {'contrail::profile::cassandra':} ->
  class {'contrail::profile::zookeeper':} ->
  class {'contrail::profile::rabbitmq':} ->
  class {'contrail::profile::redis::misc':} ->
  class {'contrail::profile::redis::query':} ->
  class {'contrail::profile::redis::uve':} ->
  class {'contrail::profile::redis::webui':} ->
  class {'contrail::profile::ifmapserver':
    require => [Class['contrail::profile::opencontrailppa'], Class['contrail::profile::lib']],
} ->
  class {'contrail::profile::utils':} ->
  class {'contrail::profile::discovery':} ->
  class {'contrail::profile::apiserver':} ->
  class {'contrail::profile::schema_transformer':} ->
  class {'contrail::profile::svc_monitor':} ->
  class {'contrail::profile::control_node': } ->
  class {'contrail::profile::dnsd': } ->
  class {'contrail::profile::neutron::server': } ~>
  exec{'restart contrail-api':
    command     => '/usr/sbin/service contrail-api restart',
    refreshonly => true,
  } ->
  class {'contrail::profile::analytics::collector':} ->
  class {'contrail::profile::analytics::query_engine':} ->
  class {'contrail::profile::analytics::analytics_api':} ->
  class {'contrail::profile::provision_linklocal': } ->
  class {'contrail::profile::provision_bgp_peers': } ->
  class {'contrail::profile::provision_vrouter':
    action => 'import',
  } ->
  class { 'contrail::profile::webui': }

  if $::is_virtual == 'true' {
    class {'contrail::profile::provision_simple_gateway':
      action => 'create_network',
    }
  }

}
