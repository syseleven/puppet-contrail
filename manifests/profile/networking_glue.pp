class contrail::profile::networking_glue() {

  $contrail_version = hiera('contrail::version', '1.06')

  if $contrail_version == '1.06' {
    $template_file = "$module_name/configure_network_interfaces.1.06.erb"
  } else {
    $template_file = "$module_name/configure_network_interfaces.erb"
  }

  file {'/usr/local/bin/configure_network_interfaces':
    ensure  => file,
    mode    => '0555',
    content => template($template_file),
  }

  exec {'configure_network_interfaces':
    command  => '/usr/local/bin/configure_network_interfaces',
    path     => '/usr/bin/:/bin/:/sbin/:/usr/sbin/',
    unless   => '[ -f /etc/network/interfaces.d/vhost0.cfg ]',
    provider => shell,
    require  => [File['/usr/local/bin/configure_network_interfaces'], Kmod::Load['vrouter']],
  }
}

