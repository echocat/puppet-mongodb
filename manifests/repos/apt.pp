# == class mongodb::repos::apt
class mongodb::repos::apt {
  $source_location = $::operatingsystem ? {
    'Ubuntu' => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart',
    default  => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
  }

  apt::source{ '10gen':
    location    => $source_location,
    release     => 'dist',
    repos       => '10gen',
    key         => '7F0CEB10',
    key_server  => 'keyserver.ubuntu.com',
    include_src => false,
  }
}
  