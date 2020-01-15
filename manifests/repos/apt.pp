# == class mongodb::repos::apt
class mongodb::repos::apt (
  $package_ensure = $::mongodb::package_ensure,
  $use_enterprise = $::mongodb::use_enterprise,
) {

  # define ordering
  Class['mongodb::repos::apt']
  -> Class['apt::update']
  -> Package<| title == 'mongo' |>

  if (($package_ensure =~ /(\d+\.*)+\d/) and (versioncmp($package_ensure, '3.0.0') >= 0)) {
    $mongover = split($package_ensure, '[.]')
    $package_name = $::mongodb::package_name

    case $::operatingsystem {
      'Debian': {
        $repos = 'main'
        # FIXME: for the moment only Debian 'Wheezy' is supported
        if ($use_enterprise) {
          $location = 'http://repo.mongodb.com/apt/debian'
          $release = "${::lsbdistcodename}/mongodb-enterprise/${$mongover[0]}.${$mongover[1]}"
        } else {
          $location = 'http://repo.mongodb.org/apt/debian'
          $release = "${::lsbdistcodename}/mongodb-org/${$mongover[0]}.${$mongover[1]}"
        }
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

    $package_name = 'mongodb-org'
    $release = 'dist'
    $repos = '10gen'
  }

  apt::source{ 'mongodb-source':
    location => $location,
    release  => $release,
    repos    => $repos,
    key      => {
      'id'     => '492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10',
      'server' => 'keyserver.ubuntu.com',
    },
  }
}
