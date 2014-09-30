class contrail::profile::zookeeper() {
  # TODO cluster mode
  include contrail::profile::zookeeper::monitoring

  package {'zookeeperd':
    ensure => latest,
  }
}
