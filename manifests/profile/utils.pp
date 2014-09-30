class contrail::profile::utils(
  $version = hiera('contrail::package_version', 'installed')
) {
  package { 'contrail-utils':
    ensure => $version,
  }
}

