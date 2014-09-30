class contrail::profile::control_node(
  $discovery_server = hiera('contrail::disc_server_ip'),
  $ifmap_username = hiera('contrail::control_node::ifmap_username'),
  $ifmap_password = hiera('contrail::control_node::ifmap_password'),
  $log_file = hiera('contrail::control_node::log_file', '/var/log/contrail/contrail-control-node.log'),
  $log_level = hiera('contrail::control_node::log_level', 'SYS_DEBUG'),
  $version = hiera('contrail::package_version', 'installed')
) {
  include contrail::profile::control_node::monitoring

  package {'contrail-control':
    ensure => $version,
  } ->

  file {'/etc/contrail/control-node.conf':
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
