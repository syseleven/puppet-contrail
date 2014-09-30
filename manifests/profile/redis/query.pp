class contrail::profile::redis::query() {
  # port 6380
  contrail::profile::redis::service {"query":
    port => 6380,
  }
}


