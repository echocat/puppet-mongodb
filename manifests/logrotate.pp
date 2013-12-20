# Class: mongodb::logrotate
#
# This module manages mongodb services.
# It provides the functions for mongod and mongos instances.
#
class mongodb::logrotate (
  $package_manage = true
) {

    anchor { 'mongodb::logrotate::begin': }
    anchor { 'mongodb::logrotate::end': }

    if ($package_manage == true) {
        package {
            'logrotate':
                ensure => installed;
        }
    }

    file {
        '/etc/logrotate.d/mongodb':
            content    => template('mongodb/logrotate.conf.erb'),
            require    => [
                Package['logrotate'],
                Class['mongodb::install'],
                Class['mongodb::params']
                ],
                before => Anchor['mongodb::logrotate::end']
    }
}
