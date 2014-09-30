class contrail::profile::packages::config_openstack(
  $version = hiera('contrail::package_version', 'installed')
) {
  package {'contrail-config-openstack':
    ensure => $version,
  }
}
