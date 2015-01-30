class contrail::profile::ifmapserver() {
  include contrail::profile::ifmapserver::monitoring

  package {'ifmap-server':
    ensure => installed,
  }

  service {'ifmap-server':
    ensure => running,
  }

  augeas { 'java-7-openjdk_java.security':
    lens => 'Properties.lns',
    incl => '/etc/java-7-openjdk/security/java.security',
    context => '/files/etc/java-7-openjdk/security/java.security',
    changes => [
      # FIXME: Reenable any disabled TLS algorithms
      #
      # This is needed because many contrail components are using hardcoded SSLv3
      # which is disabled by default in java upstream
      'rm jdk.tls.disabledAlgorithms',
    ],
    notify => Service['ifmap-server'],
  }

  file {'/etc/ifmap-server/basicauthusers.properties':
    ensure  => file,
    content => template("$module_name/ifmap-server/basicauthusers.properties.erb"),
  }
}
