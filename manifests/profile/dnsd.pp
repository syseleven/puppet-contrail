class contrail::profile::dnsd (
  $discovery_server = hiera('contrail::disc_server_ip'),
  $ifmap_username = hiera('contrail::dnsd::ifmap_username'),
  $ifmap_password = hiera('contrail::dnsd::ifmap_password'),
  $version = hiera('contrail::version', '1.06'),
) {

  if versioncmp($version, '1.10') >= 0 {

    package { 'contrail-dns':
      ensure => installed,
    }

    file { '/etc/contrail/dns/contrail-dns.conf':
      ensure  => file,
      mode    => '444',
      content => template("$module_name/contrail/contrail-dns.conf.erb"),
      require => Package['contrail-dns'],
      notify  => Service['contrail-dns'],
    }

    service { 'contrail-dns':
      ensure  => running,
      enable  => true,
      require => Package['contrail-dns'],
    }

  }

}
