class contrail::profile::lib(
  $version = hiera('contrail::package_version', 'installed')
) {
  package { 'contrail-lib':
    ensure => $version,
  }

  package { 'python-contrail':
    ensure => $version,
  }

}

