class contrail::profile::kernelppa(
  $sys11_key = '24911626',     # ppa:syseleven-platform
  ) {

  include apt

  $source = "ppa:syseleven-platform/contrail-kernel"

  apt::key { 'ppa-syseleven-platform-2.key':
    key        => $sys11_key,
  }

  exec {'aptitude update':
    path        => '/usr/bin',
    refreshonly => true,
    require     => [ Apt::Key['ppa-syseleven-platform.key'] ],
  }

  apt::ppa { $source : }

  apt::pin { 'kernel-ppa-sys11':
    originator => "LP-PPA-syseleven-platform-contrail-kernel",
    label      => "Kernels built with GCC 4.6",
    priority   => '1000',
  }

  package { 'linux-image-3.13.0-41-generic':
    ensure => "3.13.0-41.70+syseleven2",
  }

  package { 'linux-image-extra-3.13.0-41-generic':
    ensure => "3.13.0-41.70+syseleven2",
  }

  package { 'linux-headers-3.13.0-41':
    ensure => "3.13.0-41.70+syseleven2",
  }

  package { 'linux-headers-3.13.0-41-generic':
    ensure => "3.13.0-41.70+syseleven2",
  }

  package { 'linux-libc-dev:amd64':
    ensure => "3.13.0-41.70+syseleven2",
  }

  file {'/etc/grub.d/07_default':
    ensure  => file,
    mode    => '660',
    content => template("$module_name/grub/07_default.erb"),
  }

  exec{'update-grub':
    command     => "update-grub",
    require     => File['/etc/grub.d/07_default'],
    refreshonly => true,
    path        => '/usr/bin/:/bin/:/sbin/:/usr/sbin/',
  }
}