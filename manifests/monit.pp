# Class: mongodb::monit
#
# This module manages mongodb services.
# It provides the functions for mongod and mongos instances.
#
class mongodb::monit ($instance_name, $instance_port){

    anchor { 'mongodb::monit::begin': }
    anchor { 'mongodb::monit::end': }

    if ! defined(Package['monit']) {
        package {
            'monit':
                ensure => installed;
        }
    }

    case $::osfamily {
    'RedHat': {
      file {
        "/etc/monit.d/mongod_${instance_name}":
          content    => template('mongodb/mongodb.monit.erb'),
          require    => [
            Package['monit'],
            Class['mongodb::install'],
            Class['mongodb::params']
            ],
          before => Anchor['mongodb::monit::end']
      }
    }
    'Debian': {
      file {
        "/etc/monit/conf.d/mongod_${instance_name}":
          content    => template('mongodb/mongodb.monit.erb'),
          require    => [
            Package['monit'],
            Class['mongodb::install'],
            Class['mongodb::params']
            ],
          before => Anchor['mongodb::monit::end']
      }
    }
    'default': {
        notice("Currently not supported osfamily: $::osfamily")
    }
  }
}
