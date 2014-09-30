class contrail::role::compute() {
  include contrail::profile::opencontrailppa
  include contrail::profile::lib

  class {'contrail::profile::vrouter_agent':
    require => [Class['contrail::profile::opencontrailppa'], Class['contrail::profile::lib']],
  } ->
  class {'contrail::profile::nova::compute':} ->
  class {'contrail::profile::provision_vrouter':
    action => 'export',
  }
}
