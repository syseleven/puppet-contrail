class contrail::profile::webui(
  $keystone_admin_user = hiera('contrail::keystone_admin_user'),
  $keystone_admin_password = hiera('contrail::keystone_admin_password'),
  $keystone_admin_tenant_name = hiera('contrail::keystone_admin_tenant_name'),
) {

  package{'contrail-web-controller': }

  service{'contrail-webui-jobserver':
    ensure => 'running',
  }

  service{'contrail-webui-webserver':
    ensure => 'running',
  }

  file{'/etc/contrail/config.global.js':
    content => template("${module_name}/contrail/config.global.js.erb"),
    owner   => 'contrail',
    group   => 'contrail',
    mode    => '0440',
    require => Package['contrail-web-controller'],
    notify  => [Service['contrail-webui-jobserver'], Service['contrail-webui-webserver']],
  }

  file{'/etc/contrail/userAuth.js':
    content => template("${module_name}/contrail/userAuth.js.erb"),
    owner   => 'contrail',
    group   => 'contrail',
    mode    => '0440',
    require => Package['contrail-web-controller'],
    notify  => [Service['contrail-webui-jobserver'], Service['contrail-webui-webserver']],
  }
}
