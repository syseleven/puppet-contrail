class contrail::profile::kernelppa(
  $sys11_key = '24911626',
  $root_device = "/dev/system/root",
  $kernel_version = '3.16.0',
  $kernel_abi_version = '28',
  $kernel_pkg_revision = '37',
  $kernel_flavor = 'generic',
  $kernel_pkg_special_rev = '~14.04.1',
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

  package { "linux-image-$kernel_version-$kernel_abi_version-$kernel_flavor":
    ensure  => "$kernel_version-$kernel_abi_version.$kernel_pkg_revision$kernel_pkg_special_rev",
    require => [ Apt::Ppa["$source"] ],
  }

  package { "linux-image-extra-$kernel_version-$kernel_abi_version-$kernel_flavor":
    ensure  => "$kernel_version-$kernel_abi_version.$kernel_pkg_revision$kernel_pkg_special_rev",
    require => [ Apt::Ppa["$source"] ],
    notify  => Exec['install-vrouter-for-all-kernels'],
  }

  package { "linux-headers-$kernel_version-$kernel_abi_version":
    ensure  => "$kernel_version-$kernel_abi_version.$kernel_pkg_revision$kernel_pkg_special_rev",
    require => [ Apt::Ppa["$source"] ],
  }

  package { "linux-headers-$kernel_version-$kernel_abi_version-$kernel_flavor":
    ensure  => "$kernel_version-$kernel_abi_version.$kernel_pkg_revision$kernel_pkg_special_rev",
    require => [ Apt::Ppa["$source"] ],
  }

  if $::is_virtual == 'true' {
    file {'/etc/grub.d/07_default':
      ensure  => file,
      mode    => '775',
      content => template("$module_name/grub/07_default_virtual.erb"),
      notify  => Exec['update-grub'],
    }
  } else {
    file {'/etc/grub.d/07_default':
      ensure  => file,
      mode    => '775',
      content => template("$module_name/grub/07_default.erb"),
      notify  => Exec['update-grub'],
    }
  }

  exec{'update-grub':
    command     => "update-grub",
    refreshonly => true,
    path        => '/usr/bin/:/bin/:/sbin/:/usr/sbin/',
  }

}
