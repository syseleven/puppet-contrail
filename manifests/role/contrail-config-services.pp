class contrail::role::contrail-config-services(
) inherits contrail::resources::params {

  require contrail::profile::utils

  class {'contrail::profile::ifmapserver':
    require => Class['contrail::profile::opencontrailppa'],
  }
  class {'contrail::profile::discovery':}
  class {'contrail::profile::schema_transformer':}
  class {'contrail::profile::svc_monitor':}
  class {'contrail::profile::control_node': }
  class {'contrail::profile::dnsd': }
}
