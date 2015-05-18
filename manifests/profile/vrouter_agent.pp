class contrail::profile::vrouter_agent(
  $control_node = hiera('contrail::control_node::address'),
  $discovery_server = hiera('contrail::disc_server_ip'),
  $collectors_ip = hiera('contrail::analytics::collectors::address'),
  $collectors_port = hiera('contrail::analytics::collectors::port'),
  $debug = hiera('contrail::vrouter_agent::debug', '0'),
  $http_server_port = hiera('contrail::vrouter_agent::http_server_port', '8085'),
  $log_level = hiera('contrail::vrouter_agent::log_level', 'SYS_DEBUG'),
  $max_control_nodes = hiera('contrail::vrouter_agent::log_level', '1'),
  $metadata_shared_secret = hiera('sys11stack::neutron::metadata_shared_secret'),
  $control_network_ip = hiera('contrail::vrouter_agent::control_network_ip'),
  $dns_address = hiera('contrail::dnsd::address'),
  $vhost_name = hiera('contrail::vrouter_agent::vhost_name', 'vhost0'),
  $vhost_ip = hiera('contrail::vrouter_agent::vhost_ip'),
  $vhost_gateway = hiera('contrail::vrouter_agent::vhost_gateway'),
  $vhost_physical_interface = hiera('contrail::vrouter_agent::vhost_physical_interface'),
  $max_vm_flows = hiera('contrail::vrouter_agent::max_vm_flows','5'),
  $max_system_linklocal_flows = hiera('contrail::vrouter_agent::max_system_linklocal_flows','4096'),
  $max_vm_linklocal_flows = hiera('contrail::vrouter_agent::max_vm_linklocal_flows','1024'),
  $version = hiera('contrail::package_version', 'installed'),
  $contrail_version = hiera('contrail::version', '1.06')
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

  exec{'install-vrouter-for-all-kernels':
    command     => "for i in /lib/modules/*; do dkms install vrouter/\$(dpkg -l | grep contrail-vrouter-dkms | awk '{print \$3}' | sed 's/-[0-9]*+syseleven[0-9]*//') -k `basename \$i`; done",
    subscribe   => Package['contrail-vrouter-dkms'],
    refreshonly => true,
    provider    => 'shell',
    path        => '/usr/bin/:/bin/:/sbin/:/usr/sbin/',
  }


  kmod::load { 'vrouter':
    require => Package['contrail-vrouter-agent'],
  }

  if $contrail_version == '1.06' {
    $vrouter_agent_upstart_file = 'contrail-vrouter-agent-1.06.conf'
  } else {
    $vrouter_agent_upstart_file = 'contrail-vrouter-agent.conf'
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
      source => "puppet:///modules/$module_name/upstart/$vrouter_agent_upstart_file",
      require => Package['contrail-vrouter-agent'],
      }
    }
}
