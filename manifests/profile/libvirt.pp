class contrail::profile::libvirt() {
  # http://wiki.libvirt.org/page/Guest_won%27t_start_-_warning:_could_not_open_/dev/net/tun_%28%27generic_ethernet%27_interface%29
  # service['libvirt-bin'] comes from class['nova']
  file {'/etc/libvirt/qemu.conf':
    ensure => file,
    mode   => 0444,
    source => "puppet:///modules/$module_name/libvirt/qemu.conf",
    notify => Service['libvirt-bin'],
  }
}
