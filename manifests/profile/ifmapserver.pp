class contrail::profile::ifmapserver() {
  include contrail::profile::ifmapserver::monitoring

  package {'ifmap-server':
    ensure => installed,
  }

  file {'/etc/ifmap-server/basicauthusers.properties':
    ensure  => file,
    content => template("$module_name/ifmap-server/basicauthusers.properties.erb"),
  }
}
