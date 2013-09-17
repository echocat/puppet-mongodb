# == Class: mongodb
#
class mongodb (

	$run_as_user     = undef,
	$run_as_group    = undef,
	$dbdir           = undef,
	$logdir          = undef,

) inherits mongodb::params {

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

  Anchor['mongodb::install::end']
  ->
  # using exec, because puppet Service class will error on subsequent puppet agent runs after the init.d file is deleted
  # err: /Stage[main]/Mongodb/Service[mongodb]: Could not evaluate: Could not find init script or upstart conf file for 'mongodb'
  exec { 'stop-default-mongod-service':
    command => "service ${::mongodb::params::old_servicename} stop",
    onlyif  => "test -f /etc/init.d/${::mongodb::params::old_servicename}",
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  }
  ->
	# remove not wanted startup script, because it would kill all mongod instances
	# and not only the default mongod
	file {
		"/etc/init.d/${::mongodb::params::old_servicename}":
			ensure => absent,
	}
  -> Anchor['mongodb::end']
  

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

