class contrail::profile::webui() {

package{'contrail-web-controller': }

service{'contrail-webui-jobserver':
  ensure => 'running',
}

service{'contrail-webui-webserver':
  ensure => 'running',
}

  file{'/etc/contrail/config.global.js':
    content => template("${module_name}/contrail/config.global.js.erb"),
    mode    => '0644',
    require => Package['contrail-web-controller'],
    notify  => [Service['contrail-webui-jobserver'], Service['contrail-webui-webserver']],
  }

  file{'/etc/contrail/userAuth.js':
    content => template("${module_name}/contrail/userAuth.js.erb"),
    mode    => '0644',
    require => Package['contrail-web-controller'],
    notify  => [Service['contrail-webui-jobserver'], Service['contrail-webui-webserver']],
  }

}
