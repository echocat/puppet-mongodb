# Class: mongodb::logrotate
#
# This module manages mongodb services.
# It provides the functions for mongod and mongos instances.

class mongodb::logrotate {

	anchor { 'mongodb::logrotate::begin': }
	anchor { 'mongodb::logrotate::end': }

	if ! defined(Package['logrotate']) {
		package {
			'logrotate':
				ensure => installed;
		}
	}

	File {
		require => [Class['mongodb::install'],Class['mongodb::params']]
	}

	file {
		'/etc/logrotate.d/mongodb':
			content => template('mongodb/logrotate.conf.erb'),
			require => Package['logrotate'],
			before => Anchor['mongodb::logrotate::end']
	}
}