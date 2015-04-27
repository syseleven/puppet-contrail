class contrail::role::contrail-api-services() {

  require contrail::profile::opencontrailppa

  class {'contrail::profile::apiserver':} ->
  class {'contrail::profile::neutron::server': } ~>
  exec{'restart contrail-api':
    command     => '/usr/sbin/service contrail-api restart',
    refreshonly => true,
  } ->
  class {'contrail::profile::analytics::analytics_api':} ->
  class {'contrail::profile::provision_linklocal': } ->
  class {'contrail::profile::provision_bgp_peers': } ->

  if $::is_virtual == 'true' {
    class {'contrail::profile::provision_floating_ips':
      action => 'create_network',
    }
  }

}
