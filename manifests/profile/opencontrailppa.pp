class contrail::profile::opencontrailppa() {
  apt::key { 'contrail.key':
    key        => '6839FE77',
  } 

  # FIXME use better classes
  exec {'echo | add-apt-repository ppa:opencontrail/ppa':
    path     => '/usr/bin',
    provider => 'shell',
    unless   => '[ -f /etc/apt/sources.list.d/opencontrail-ppa-precise.list ]',
  } ->

  # TODO apt::source
  file {'/etc/apt/sources.list.d/opencontrail-ppa-precise.list':
    ensure  => file,
    content => 'deb http://ppa.launchpad.net/opencontrail/snapshots/ubuntu precise main
deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu precise main
',
  } ~>

  exec {'aptitude update':
    path        => '/usr/bin',
    refreshonly => true,
    require     => Apt::Key['contrail.key'],
  }

  # FIXME snapshot of 1.06 .debs because opencontrail repo sometimes misses them
  apt::source { 'contrail_repo_sys11_snapshot':
    location    => 'https://files.syseleven.de/~sandres/contrail_deb ',
    release     => '',
    repos       => 'binary/',
    include_src => false,
  }
}

