class contrail::profile::redis::webui() {
  # port 6383
  contrail::profile::redis::service {"webui":
    port => 6383,
  }
}


