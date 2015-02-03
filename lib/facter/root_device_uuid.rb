# 2015, j.grassler@syseleven.de

# This fact returns the UUID of the partition that is currently mounted as root
# file system.

Facter.add('root_device_uuid') do
  setcode do
    root_uuid = ''
    partitions = Facter.value(:partitions)
    partitions.each { |key, value|
      if ( value['mount'] == '/' )
        root_uuid = value['uuid']
      end
      }

    root_uuid
  end
end
