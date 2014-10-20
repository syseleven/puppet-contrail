class contrail::profile::redis::package() {
  if versioncmp($::operatingsystemrelease, '14') < 0 {
    # ubuntu-12 does not have a recent enough redis-server
    # needing at least 2.6.8
    apt::key { 'redis.key':
      key        => '5862E31D',
    }

    # FIXME use better classes
    exec {'echo | add-apt-repository  ppa:rwky/redis':
      path     => '/usr/bin',
      provider => 'shell',
      unless   => '[ -f /etc/apt/sources.list.d/rwky-redis-precise.list ]',
      before   => Package['redis-server'],
    } ~>

    exec {'aptitude update redis':
      command     => 'aptitude update',
      path        => '/usr/bin',
      refreshonly => true,
      require     => Apt::Key['redis.key'],
    }
  }

  package {'redis-server':
    ensure  => latest,
  }
}
