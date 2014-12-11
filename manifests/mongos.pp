# == definition mongodb::mongos
define mongodb::mongos (
  $mongos_configServers,
  $mongos_instance       = $name,
  $mongos_bind_ip        = '',
  $mongos_port           = 27017,
  $mongos_service_manage = true,
  $mongos_enable         = true,
  $mongos_running        = true,
  $mongos_logappend      = true,
  $mongos_fork           = true,
  $mongos_useauth        = false,
  $mongos_add_options    = []
) {
  file {
    "/etc/mongos_${mongos_instance}.conf":
      content => template('mongodb/mongos.conf.erb'),
      mode    => '0755',
      # no auto restart of a db because of a config change
      #notify => Class['mongodb::service'],
      require => Class['mongodb::install'];
    "/etc/init.d/mongos_${mongos_instance}":
      content => $::osfamily ? {
        Debian => template('mongodb/debian_mongos-init.conf.erb'),
        RedHat => template('mongodb/redhat_mongos-init.conf.erb'),
      },
      mode    => '0755',
      require => Class['mongodb::install'],
  }

  if ($mongos_useauth != false){
    file { "/etc/mongos_${mongos_instance}.key":
      content => template('mongodb/mongos.key.erb'),
      mode    => '0700',
      owner   => $::mongodb::run_as_user,
      require => Class['mongodb::install'],
      notify  => Service["mongos_${mongos_instance}"],
    }
  }

  if ($mongos_service_manage == true){
    service {
      "mongos_${mongos_instance}":
        ensure     => $mongos_running,
        enable     => $mongos_enable,
        hasstatus  => true,
        hasrestart => true,
        require    => [
          File["/etc/mongos_${mongos_instance}.conf"],
          File["/etc/init.d/mongos_${mongos_instance}"],
          Service[$::mongodb::old_servicename]
        ],
        before     => Anchor['mongodb::end']
    }
  }

}
