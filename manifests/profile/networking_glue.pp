class contrail::profile::networking_glue() {
  file {'/usr/local/bin/configure_network_interfaces':
    ensure  => file,
    mode    => '0555',
    content => template("$module_name/configure_network_interfaces.erb"),
  }

  exec {'configure_network_interfaces':
    command  => '/usr/local/bin/configure_network_interfaces',
    path     => '/usr/bin/:/bin/:/sbin/:/usr/sbin/',
    unless   => '[ -f /etc/network/interfaces.d/vhost0.cfg ]',
    provider => shell,
    require  => [File['/usr/local/bin/configure_network_interfaces'], Kmod::Load['vrouter']],
  }
}

