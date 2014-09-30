class contrail::profile::redis::package() {
  apt::key { 'redis.key':
    key        => '5862E31D',
  } 

  # FIXME use better classes
  # need recent redis version, at least 2.6.8
  exec {'echo | add-apt-repository  ppa:rwky/redis':
    path     => '/usr/bin',
    provider => 'shell',
    unless   => '[ -f /etc/apt/sources.list.d/rwky-redis-precise.list ]',
  } ~>

  exec {'aptitude update redis':
    command     => 'aptitude update',
    path        => '/usr/bin',
    refreshonly => true,
    require     => Apt::Key['redis.key'],
  } 

  package {'redis-server':
    ensure  => latest,
    require => Exec['echo | add-apt-repository  ppa:rwky/redis'],
  }
}
