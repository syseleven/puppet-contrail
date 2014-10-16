class contrail::profile::opencontrailppa(
  $sys11_key = '24911626',     # ppa:syseleven-platform
  $upstream_key = '6839FE77',  # ppa:opencontrail
  $source = 'ppa:syseleven-platform/contrail-1.06',
  ) {

  include apt

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

  # FIXME snapshot of 1.06 .debs because opencontrail repo sometimes misses them
#  apt::source { 'contrail_repo_sys11_snapshot':
#    location    => 'https://files.syseleven.de/~sandres/contrail_deb',
#    release     => '',
#    repos       => 'binary/',
#    include_src => false,
}

