class contrail::role::contrail-analytics-services(
) inherits contrail::resources::params {

  class {'contrail::profile::analytics::collector':}
  class {'contrail::profile::analytics::query_engine':}
}
