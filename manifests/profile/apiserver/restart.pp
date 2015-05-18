class contrail::profile::apiserver::restart() {
  # dirty workaround because contrail-api needs to be restarted manually
  # because it does not heal itself after initial deployment
  if $::is_virtual {
    exec{'restart contrail-api':
      command  => '/usr/sbin/service contrail-api restart',
      provider => 'shell',
      onlyif   => 'bash -c ". /root/openrc; [[ \"$(neutron net-list 2>&1)\" == *HTTP\ 500* ]]"'
    }
  }
}

