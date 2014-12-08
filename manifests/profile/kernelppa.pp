class contrail::profile::kernelppa(
  $sys11_key = '24911626',     # ppa:syseleven-platform
  $kernel_version = "3.13.0-41-generic",
  $kernel_major_version = "3.13.0-41.70",
  $kernel_api_version = "3.13.0-41",
  $revision = "2",
  $root_device = "/dev/system/root",
  ) {

  include apt

  $source = "ppa:syseleven-platform/contrail-kernel"

  apt::key { 'ppa-syseleven-platform-2.key':
    key        => $sys11_key,
  }

  exec {'update package sources':
    path        => '/usr/bin',
    refreshonly => true,
    command     => "aptitude update",
    require     => [ Apt::Key['ppa-syseleven-platform.key'] ],
  }

  apt::ppa { $source : }

  apt::pin { 'kernel-ppa-sys11':
    originator => "LP-PPA-syseleven-platform-contrail-kernel",
    label      => "Kernels built with GCC 4.6",
    priority   => '1000',
  }

  package { 'linux-image-$kernel_version':
    ensure  => "$kernel_major_version+syseleven$revision",
    require => [ Apt::Ppa["$source"] ],
  }

  package { 'linux-image-extra-$kernel_version':
    ensure  => "$kernel_major_version+syseleven$revision",
    require => [ Apt::Ppa["$source"] ],
  }

  package { 'linux-headers-$kernel_api_version':
    ensure  => "$kernel_major_version+syseleven$revision",
    require => [ Apt::Ppa["$source"] ],
  }

  package { 'linux-headers-$kernel_version':
    ensure  => §$kernel_major_version+syseleven$revision",
    require => [ Apt::Ppa["$source"] ],
  }

  package { 'linux-libc-dev:amd64':
    ensure  => "$kernel_major_version+syseleven$revision",
    require => [ Apt::Ppa["$source"] ],
  }

  package { 'gcc-4.6':
    ensure => installed,
  }

  package { 'g++-4.6':
    ensure => installed,
  }

  file {'/etc/grub.d/07_default':
    ensure  => file,
    mode    => '775',
    content => template("$module_name/grub/07_default.erb"),
    notify  => Exec['update-grub'],
  }

  exec{'update-grub':
    command     => "update-grub",
    require     => File['/etc/grub.d/07_default'],
    refreshonly => true,
    path        => '/usr/bin/:/bin/:/sbin/:/usr/sbin/',
  }
}
