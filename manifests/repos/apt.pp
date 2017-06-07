# == class mongodb::repos::apt
class mongodb::repos::apt (
  $package_ensure = $::mongodb::package_ensure,
) {

  # define ordering
  Class['mongodb::repos::apt']
  -> Class['apt::update']
  -> Package<| title == 'mongo' |>

  if (($package_ensure =~ /(\d+\.*)+\d/) and (versioncmp($package_ensure, '3.0.0') >= 0)) {
    $mongover = split($package_ensure, '[.]')
    $package_name = 'mongodb-org'

    case $::operatingsystem {
      'Debian': {
        $location = 'http://repo.mongodb.org/apt/debian'
        $repos = 'main'
        # FIXME: for the moment only Debian 'Wheezy' is supported
        $release = "wheezy/mongodb-org/${$mongover[0]}.${$mongover[1]}"
      }
      'Ubuntu': {
        $location = 'http://repo.mongodb.org/apt/ubuntu'
        $release = "${::lsbdistcodename}/mongodb-org/${$mongover[0]}.${$mongover[1]}"
        $repos = 'multiverse'
      }
      default: {
        fail("Unsupported managed repository for operatingsystem: ${::operatingsystem}, module ${::module_name} currently only supports managing repos for operatingsystem Debian and Ubuntu")
      }
    }
  } else {
    $location = $::operatingsystem ? {
      'Ubuntu' => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart',
      default  => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
    }

    if ($mongodb::package_name == undef) {
      $package_name = 'mongodb-10gen'
    } else {
      $package_name = $mongodb::package_name
    }
    
    $release = 'dist'
    $repos = '10gen'
  }

  apt::source{ 'mongodb-source':
    location    => $location,
    release     => $release,
    repos       => $repos,
    key         => '492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10',
    key_server  => 'keyserver.ubuntu.com',
    include_src => false,
  }
}
