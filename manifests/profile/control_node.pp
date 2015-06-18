class contrail::profile::control_node(
  $discovery_server = hiera('contrail::disc_server_ip'),
  $ifmap_username = hiera('contrail::control_node::ifmap_username'),
  $ifmap_password = hiera('contrail::control_node::ifmap_password'),
  $log_file = hiera('contrail::control_node::log_file', '/var/log/contrail/contrail-control-node.log'),
  $log_level = hiera('contrail::control_node::log_level', 'SYS_DEBUG'),
  $version = hiera('contrail::package_version', 'installed'),
  $collectors = $contrail::resources::params::collectors,
) {
  include contrail::profile::control_node::monitoring

  $contrail_version = hiera('contrail::version', '1.06')

  if $contrail_version == '1.06' {
    $control_config_file = '/etc/contrail/control-node.conf'
  } else {
    $control_config_file = '/etc/contrail/contrail-control.conf'
  }

  package {'contrail-control':
    ensure => $version,
  } ->

  file {$control_config_file:
    ensure  => file,
    mode    => '444',
    content => template("$module_name/contrail/control-node.conf.erb"),
    notify  => Service['contrail-control'],
  }

  service {'contrail-control':
    ensure => running,
    enable => true,
  }
}
