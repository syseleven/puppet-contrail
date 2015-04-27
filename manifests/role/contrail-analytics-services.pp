class contrail::role::contrail-analytics-services() {

  require contrail::profile::opencontrailppa

  class {'contrail::profile::analytics::collector':}
  class {'contrail::profile::analytics::query_engine':}
}
