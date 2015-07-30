class contrail::role::contrail-api-services(
) inherits contrail::resources::params {

  class {'contrail::profile::apiserver':} ->
  class {'contrail::profile::neutron::server': } ~>
  exec{'restart contrail-api':
    command     => '/usr/sbin/service contrail-api restart',
    refreshonly => true,
  } ->
  class {'contrail::profile::analytics::analytics_api':} ->
  class {'contrail::profile::provision_linklocal': } ->
  class {'contrail::profile::provision_bgp_peers': }
  class {'contrail::profile::provision_floating_ip_networks': }
  class {'contrail::profile::apiserver::restart': }

  class {'contrail::profile::provision_vrouter':
    action => 'import',
  }

  if $::is_virtual == 'true' {
    class {'contrail::profile::provision_floating_ips':
      action => 'create_network',
    }
  }

}
