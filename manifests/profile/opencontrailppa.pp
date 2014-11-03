class contrail::profile::opencontrailppa(
  $sys11_key = '24911626',     # ppa:syseleven-platform
  $upstream_key = '6839FE77',  # ppa:opencontrail
  $version = hiera('contrail::version'),
  ) {

  include apt

  $source = "ppa:syseleven-platform/contrail-$version"

  apt::key { 'contrail.key':
    key        => $upstream_key,
  }

  apt::key { 'ppa-syseleven-platform.key':
    key        => $sys11_key,
  }

  exec {'aptitude update':
    path        => '/usr/bin',
    refreshonly => true,
    require     => [ Apt::Key['contrail.key'], Apt::Key['ppa-syseleven-platform.key'] ],
  }

  apt::ppa { 'ppa:opencontrail/ppa': }
  apt::ppa { $source : }

  apt::pin { 'contrail-ppa-sys11':
    originator => "LP-PPA-syseleven-platform-contrail-$version",
    label      => "Contrail $version",
    priority   => '1000',
  }

  if $version == '1.06' {
    # FIXME contrail-web-core depends on nodejs version 0.8.15-1contrail1
    # only works for contrail-1.06
    apt::pin { 'nodejs':
      packages => 'nodejs',
      version  => '0.8.15-1contrail1',
      priority => '990',
    }
  }
}

