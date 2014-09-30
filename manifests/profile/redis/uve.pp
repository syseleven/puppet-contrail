class contrail::profile::redis::uve() {
  # port 6381
  contrail::profile::redis::service {"uve":
    port => 6381,
  }
}


