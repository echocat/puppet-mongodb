# == Class: mongodb::params
#
class mongodb::params {

  $use_enterprise = false
  $use_yamlconfig = false

  if ($use_enterprise) {
    ## FIXME: only Debian supported at the moment
    case $::osfamily {
      'Debian': {
        $repo_class          = 'mongodb::repos::apt'
        $mongodb_pkg_name    = 'mongodb-enterprise'
        $old_server_pkg_name = 'mongodb-stable'
        $old_servicename     = 'mongodb'
        $run_as_user         = 'mongodb'
        $run_as_group        = 'mongodb'
        $logdir              = '/var/log/mongodb'
      }
      default: {
        fail("Unsupported OS ${::osfamily}")
      }
    }
  } else {
    case $::osfamily {
      'Debian': {
        $repo_class          = 'mongodb::repos::apt'
        $mongodb_pkg_name    = 'mongodb-10gen'
        $old_server_pkg_name = 'mongodb-stable'
        $old_servicename     = 'mongodb'
        $run_as_user         = 'mongodb'
        $run_as_group        = 'mongodb'
        $logdir              = '/var/log/mongodb'
      }
      'RedHat': {
        $repo_class          = 'mongodb::repos::yum'
        $mongodb_pkg_name    = 'mongo-10gen-server'
        $old_server_pkg_name = 'mongodb-server'
        $old_servicename     = 'mongod'
        $run_as_user         = 'mongod'
        $run_as_group        = 'mongod'
        $logdir              = '/var/log/mongodb'
      }
      default: {
        fail("Unsupported OS ${::osfamily}")
      }
    }
  }

  case $::osfamily {
    'Debian': {
      if ($::operatingsystem == 'Ubuntu') {
        $systemd_os = versioncmp($::operatingsystemmajrelease, '15.10') > 0
      } else {
        $systemd_os = versioncmp($::operatingsystemmajrelease, '8') >= 0
      }
    }
    'RedHat': {
      $systemd_os = versioncmp($::operatingsystemmajrelease, '7') >= 0
    }
    default: { # deal with lint
      $systemd_os = false
    }
  }

    # directorypath to store db directory in
    # subdirectories for each mongo instance will be created

    $dbdir = '/var/lib'

    # numbers of files (days) to keep by logrotate

    $logrotatenumber = 7

    # package version / installed / absent

    $package_ensure = 'installed'

    # should this module manage the mongodb repository from upstream?

    $repo_manage = true

    # should this module manage the logrotate package?

    $logrotate_package_manage = true

    # specify ulimit - nofile = 64000 and nproc = 64000 is recommended setting from
    # https://docs.mongodb.com/manual/reference/ulimit/#recommended-ulimit-settings

    $ulimit_nofiles = 64000
    $ulimit_nproc   = 64000

    # specify pidfilepath

    $pidfilepath = $dbdir

}
