class contrail::profile::packages::analytics(
  $version = hiera('contrail::package_version', 'installed')
) {
  package {'contrail-analytics':
    ensure => $version,
  }
}
