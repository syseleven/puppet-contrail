class contrail::profile::rabbitmq() {
  if ! defined(Class['rabbitmq::server']) {
    # TODO call rabbitmq::server class
    #fail('You need to configure rabbitmq::server. It could be configure via nova::rabbitmq')
  }
}
