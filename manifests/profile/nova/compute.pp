class contrail::profile::nova::compute(
  $version = hiera('contrail::package_version', 'installed')
) {
  # TODO neutron.conf currently solved in sys11stack::profile::nova/compute.pp

  class {'contrail::profile::libvirt':}

  package {'contrail-nova-driver':
    ensure => $version,
    #before => Class['sys11stack::profile::neutron::common'],
    notify  => Service['nova-compute'],
  }
}
