class contrail::role::contrail-web-services(
) inherits contrail::resources::params {

  class { 'contrail::profile::webui': }
}
