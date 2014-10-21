#puppet module install gini-cassandra
#curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
#sudo sh -c 'echo "deb http://debian.datastax.com/community/ stable main" >> /etc/apt/sources.list.d/datastax.list'
#aptitude update
#aptitude remove openjdk-6-jre-headless icedtea-6-jre-jamvm icedtea-6-jre-cacao openjdk-6-jre-lib default-jre-headless
#apt-get install -y openjdk-7-jre
#apt-get install -y cassandra

class contrail::profile::cassandra() {
  # TODO cluster mode
  # gpg --import <(curl -L http://debian.datastax.com/debian/repo_key)
  # gpg --list-keys

  include contrail::profile::cassandra::monitoring

  apt::key { 'datastax.key':
    key        => 'B999A372',
    key_source => 'http://debian.datastax.com/debian/repo_key',
  }

  apt::source { 'datastax.repo':
    location    => 'http://debian.datastax.com/community/',
    release     => 'stable',
    repos       => 'main',
    key         => 'B999A372',
    include_src => false,
  }


  package {'openjdk-7-jre':
    ensure  => latest,
    require => Apt::Source['datastax.repo'],
  }

  alternatives { 'java':
    path    => '/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java',
    require => Package['openjdk-7-jre'],
  }

  package {'cassandra':
    ensure  => latest,
    require => [Package['openjdk-7-jre'], Alternatives['java']],
  }
}

