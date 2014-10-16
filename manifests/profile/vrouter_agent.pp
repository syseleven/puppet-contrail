class contrail::profile::vrouter_agent(
  $control_node = hiera('contrail::control_node::address'),
  $collectors_ip = hiera('contrail::analytics::collectors::address'),
  $collectors_port = hiera('contrail::analytics::collectors::port'),
  $debug = hiera('contrail::vrouter_agent::debug', '1'),
  $http_server_port = hiera('contrail::vrouter_agent::http_server_port', '8085'),
  $log_level = hiera('contrail::vrouter_agent::log_level', 'SYS_DEBUG'),
  $max_control_nodes = hiera('contrail::vrouter_agent::log_level', '1'),
  $dns_servers = hiera('contrail::vrouter_agent::dns_servers', 'undef'), #TODO
  $metadata_shared_secret = hiera('sys11stack::neutron::metadata_shared_secret'),
  $control_network_ip = hiera('contrail::vrouter_agent::control_network_ip'),
  $vhost_name = hiera('contrail::vrouter_agent::vhost_name', 'vhost0'),
  $vhost_ip = hiera('contrail::vrouter_agent::vhost_ip'),
  $vhost_gateway = hiera('contrail::vrouter_agent::vhost_gateway'),
  $vhost_physical_interface = hiera('contrail::vrouter_agent::vhost_physical_interface'),
  $version = hiera('contrail::package_version', 'installed')
) {
  include contrail::profile::vrouter_agent::monitoring

  $collectors = "${collectors_ip}:${collectors_port}"

  package {'contrail-vrouter-utils':
    ensure => $version,
  } ->

  package {'contrail-vrouter-dkms':
    ensure => $version,
  } ->

  package {'contrail-vrouter-agent':
    ensure => $version,
  }

  # Ensure the vrouter module is available for all installed kernels:

  $vrouter_version = regsubst($version, "-.*", '')  # Strip Debian package versioning (the source directory name contains just the upstream version)

  notify{ "vrouter_version: $vrouter_version": }
  exec{'build-vrouter-for-all-kernels':
    command     => "for i in /lib/modules/*; do dkms build vrouter/$vrouter_version -k `basename \$i`; done",
    subscribe   => Package['contrail-vrouter-dkms'],
    refreshonly => true,
    provider    => 'shell',
    path        => '/usr/bin/:/bin/:/sbin/:/usr/sbin/',
  }

  exec{'install-vrouter-for-all-kernels':
    command     => "for i in /lib/modules/*; do dkms install vrouter/$vrouter_version -k `basename \$i`; done",
    subscribe   => Exec['build-vrouter-for-all-kernels'],
    refreshonly => true,
    provider    => 'shell',
    path        => '/usr/bin/:/bin/:/sbin/:/usr/sbin/',
  }


  kmod::load { 'vrouter': 
    require => Package['contrail-vrouter-agent'],
  }

  file {'/etc/contrail/contrail-vrouter-agent.conf':
    ensure  => file,
    mode    => '444',
    content => template("$module_name/contrail/contrail-vrouter-agent.conf.erb"),
    require => Package['contrail-vrouter-agent'],
    notify  => Service['contrail-vrouter-agent'],
  } ~>

  service {'contrail-vrouter-agent':
    ensure => running,
    enable => true,
  }

  # Ensures vrouter agent is started before networking on dev clouds.
  # (without it vhost0 will come up but won't be able to DHCP)

  if $::is_virtual {
    file { '/etc/init/contrail-vrouter-agent.conf':
      ensure => file,
      mode   => '0644',
      source => "puppet:///modules/$module_name/upstart/contrail-vrouter-agent.conf",
      require => Package['contrail-vrouter-agent'],
      }
    }
}
