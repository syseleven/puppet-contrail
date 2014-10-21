class contrail::profile::lib(
  $version = hiera('contrail::package_version', 'installed')
) {
  require contrail::profile::opencontrailppa

  package { 'contrail-lib':
    ensure => $version,
  }

  package { 'python-contrail':
    ensure => $version,
  }

}

