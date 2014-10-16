class contrail::profile::opencontrailppa(
  $key = '24911626',
  $source = 'ppa:syseleven-platform/contrail-1.06',
  ) {
  apt::key { 'contrail.key':
    key        => $key,
  } 

  exec {'aptitude update':
    path        => '/usr/bin',
    refreshonly => true,
    require     => Apt::Key['contrail.key'],
  }

  apt::ppa { 'ppa:opencontrail/ppa': }

  apt::ppa { $source : }

  # FIXME snapshot of 1.06 .debs because opencontrail repo sometimes misses them
#  apt::source { 'contrail_repo_sys11_snapshot':
#    location    => 'https://files.syseleven.de/~sandres/contrail_deb',
#    release     => '',
#    repos       => 'binary/',
#    include_src => false,
}

