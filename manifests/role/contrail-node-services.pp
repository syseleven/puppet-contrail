class contrail::role::contrail-node-services(
) inherits contrail::resources::params {

  class {'contrail::profile::vrouter_agent':
    require => Class['contrail::profile::opencontrailppa'],
  } ->
  class {'contrail::profile::nova::compute':} ->
  class {'contrail::profile::provision_vrouter':
    action => 'export',
  }

  if $::is_virtual == 'true' {
    class { 'contrail::profile::networking_glue': }
    class { 'contrail::profile::provision_floating_ips':
      action => 'create_vgw_device',
    }
  }
}
