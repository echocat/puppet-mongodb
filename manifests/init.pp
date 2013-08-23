# == Class: mongodb
#
class mongodb inherits mongodb::params {

    anchor{ 'mongodb::begin':
        before => Anchor['mongodb::install::begin'],
    }

    anchor { 'mongodb::end': }

    class { 'mongodb::logrotate':
        require => Anchor['mongodb::install::end'],
        before  => Anchor['mongodb::end'],
    }

    case $::osfamily {
        /(?i)(Debian|RedHat)/: {
            class { 'mongodb::install': }
        }
        default: {
            fail "Unsupported OS ${::operatingsystem} in 'mongodb' module"
        }
    }

    # stop and disable default mongod

    service {
        [$::mongodb::params::old_servicename]:
            ensure     => stopped,
            enable     => false,
            hasstatus  => true,
            hasrestart => true,
            subscribe  => Package['mongodb-10gen'],
            before     => Anchor['mongodb::end'],
    }

    # remove not wanted startup script, because it would kill all mongod
    # instances and not only the default mongod

    file {
        "/etc/init.d/${::mongodb::params::old_servicename}":
            ensure  => absent,
            require => Service[$::mongodb::params::old_servicename],
            before  => Anchor['mongodb::end'],
    }

  mongodb::limits::conf {
    'mongod-soft':
      type  => soft,
      item  => nofile,
      value => $mongodb::params::ulimit_nofiles;
    'mongod-hard':
      type  => hard,
      item  => nofile,
      value => $mongodb::params::ulimit_nofiles;
  }

}

