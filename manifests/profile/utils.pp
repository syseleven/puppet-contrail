class contrail::profile::utils(
  $version = hiera('contrail::version', '1.06'),
) {

  $source = "ppa:syseleven-platform/contrail-$version"

  package { 'contrail-utils':
    require => Apt::Ppa[$source],
  }
}

