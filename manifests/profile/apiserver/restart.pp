class contrail::profile::apiserver::restart() {
  # dirty workaround because contrail-api needs to be restarted manually
  # because it does not heal itself after initial deployment
  if $::is_virtual {
    file {'/usr/local/sbin/check_neutron_net_list':
      mode    => '0555',
      content => "#!/usr/bin/env bash\n. /root/openrc\n[[ $(neutron net-list 2>&1) == *HTTP\ 500* ]]",
    } ->
    exec{'restart contrail-api on error 500':
      command  => '/usr/sbin/service contrail-api restart; date > /tmp/contrail-api_restarted',
      provider => 'shell',
      onlyif   => '/usr/local/sbin/check_neutron_net_list',
    }
  }
}

