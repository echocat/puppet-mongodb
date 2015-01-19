# Class: mongodb::logrotate
#
# This module manages mongodb services.
# It provides the functions for mongod and mongos instances.
#
class mongodb::logrotate {

  anchor { 'mongodb::logrotate::begin': }
  anchor { 'mongodb::logrotate::end': }

  logrotate::rule { 'mongodb':
    path          => "${::mongodb::logdir}/*.log",
    rotate        => $::mongodb::logrotatenumber,
    rotate_every  => 'day',
    compress      => true,
    delaycompress => true,
    sharedscripts => true,
    create        => true,
    create_mode   => '0640',
    create_owner  => $::mongodb::run_as_user,
    create_group  => $::mongodb::run_as_group,
    missingok     => true,
    ifempty       => false,
    postrotate    => "  killall -SIGUSR1 mongod > /dev/null 2>&1 || true
      killall -SIGUSR1 mongos > /dev/null 2>&1 || true
      find ${::mongodb::logdir} -type f -regex '.*\\.\\(log.[0-9].*-[0-9].*\\)' -exec rm {} \\;",
    require       => [Class['mongodb::install'], Class['mongodb::params']],
    before        => Anchor['mongodb::logrotate::end']
  }
}
