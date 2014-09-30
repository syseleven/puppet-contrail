class contrail::profile::redis::misc() {
  # port 6379
  file {'/etc/redis/redis.conf':
    ensure => file,
    source => "puppet:///modules/$module_name/redis/redis.conf",
  } ~>

  service {'redis-server':
    ensure => running,
    enable => true,
  }

}


