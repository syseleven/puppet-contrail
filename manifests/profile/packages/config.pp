class contrail::profile::packages::config(
  $version = hiera('contrail::package_version', 'installed')
) {
  package {'contrail-config':
    ensure  => $version,
  }
}
