class contrail::profile::servicemonitor(
  $version = hiera('contrail::package_version', 'installed')
) {
  package { 'contrail-config-openstack':
    ensure => $version,
  }
  # TODO config
}

