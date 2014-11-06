class contrail::profile::dnsd (
  $discovery_server = hiera('contrail::disc_server_ip'),
  $ifmap_username = hiera('contrail::control_node::ifmap_username'),
  $ifmap_password = hiera('contrail::control_node::ifmap_password'),
) {

  package { 'contrail-dns':
    ensure => installed,
  }

  file { '/etc/contrail/dns/dns.conf':
    ensure  => file,
    mode    => '444',
    content => template("$module_name/contrail/dns.conf.erb"),
    require => Package['contrail-dns'],
    notify  => Service['contrail-dns'],
  }

  file { '/etc/contrail/dns/rndc.conf':
    ensure  => file,
    mode    => '444',
    source  => "puppet:///modules/$module_name/contrail/rndc.conf",
    require => Package['contrail-dns'],
    notify  => Service['contrail-dns'],
  }

  service { 'contrail-dns':
    ensure  => running,
    enable  => true,
    require => Package['contrail-dns'],
  }

}
