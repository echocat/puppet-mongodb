# Class: mongodb::params
#
#
class mongodb::params {

	$repo_class = $operatingsystem ? {
		/(?i)(Redhat|CentOS)/ => 'yum::repo::mongodb',
	}

	$server_pkg_name = $operatingsystem ? {
		/(?i)(Debian|Ubuntu)/ => 'mongodb-10gen',
		/(?i)(Redhat|CentOS)/ => 'mongo-10gen-server',
		default               => undef,
	}

	$old_server_pkg_name = $operatingsystem ? {
		/(?i)(Debian|Ubuntu)/ => 'mongodb-stable',
		/(?i)(Redhat|CentOS)/ => 'mongodb-server',
		default               => undef,
	}

	$run_as_user = 'mongod'
	$run_as_group = 'mongod'

	# directorypath to store db directory in
	# subdirectories for each mongo instance will be created
	$dbdir = '/var/lib'
	# numbers of files to keep by logrotate
	$logrotatenumber = 7
	# directory for mongo logfiles
	$logdir = '/var/log/mongo'
}
