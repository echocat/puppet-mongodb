# == Class: mongodb::params
#
class mongodb::params {

    $repo_class = $::osfamily ? {
        redhat => 'mongodb::repos::yum',
        debian => 'mongodb::repos::apt',
    }

    $mongodb_pkg_name = $::osfamily ? {
        debian  => 'mongodb-10gen',
        redhat  => 'mongo-10gen-server',
    }

    $old_server_pkg_name = $::osfamily ? {
        debian  => 'mongodb-stable',
        redhat  => 'mongodb-server',
    }

    $old_servicename = $::osfamily ? {
        debian  => 'mongodb',
        redhat  => 'mongod',
    }

    $run_as_user = $::osfamily ? {
        debian  => 'mongodb',
        redhat  => 'mongod',
    }

    $run_as_group = $::osfamily ? {
        debian  => 'mongodb',
        redhat  => 'mongod',
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

    # directory for mongo logfiles

    $logdir = $::osfamily ? {
        debian  => '/var/log/mongodb',
        redhat  => '/var/log/mongo',
    }

    # specify ulimit - nofile = 64000 and nproc = 32000 is recommended setting from
    # http://docs.mongodb.org/manual/reference/ulimit/#recommended-settings

    $ulimit_nofiles = 64000
    $ulimit_nproc   = 32000

    # specify pidfilepath

    $pidfilepath = $dbdir

}
