class contrail::role::contrail-web-services() {

  require contrail::profile::opencontrailppa

  class { 'contrail::profile::utils': }
  class { 'contrail::profile::webui': }
}
