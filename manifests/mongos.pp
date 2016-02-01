# == definition mongodb::mongos
define mongodb::mongos (
  $mongos_configServers,
  $mongos_instance         = $name,
  $mongos_bind_ip          = '',
  $mongos_port             = 27017,
  $mongos_service_manage   = true,
  $mongos_enable           = true,
  $mongos_running          = true,
  $mongos_logappend        = true,
  $mongos_fork             = true,
  $mongos_useauth          = false,
  $mongos_starttime        = 1,
  $mongos_add_options      = []
) {

# lint:ignore:selector_inside_resource  would not add much to readability

  file {
    "/etc/mongos_${mongos_instance}.conf":
      content => template('mongodb/mongos.conf.erb'),
      mode    => '0755',
      require => Class['mongodb::install'];
    "/etc/init.d/mongos_${mongos_instance}":
      content => template("mongodb/mongos_init/${::osfamily}/init.conf.erb"),
      mode    => '0755',
      require => Class['mongodb::install'];
  }

  if ($::osfamily == 'Debian' and $::operatingsystemmajrelease == 8) {
    file { "mongos_${mongos_instance}_systemd_service":
        path    => "/lib/systemd/system/mongos_${mongos_instance}.service",
        content => template("mongodb/mongos_init/${::osfamily}/systemd.conf.erb"),
        mode    => '0644',
        before  => Exec["systemctl_${mongos_instance}_reload"],
        require => [
          Class['mongodb::install'],
          File["/etc/init.d/mongos_${mongos_instance}"]
        ],
    }

    # ensure daemon-reload has been done before service start

    exec { "systemctl_${mongos_instance}_reload":
      command => 'systemctl daemon-reload',
      path    => '/bin',
      before  => Service["mongos_${mongos_instance}"],
    }
  }

  # wait for servers starting

  start_detector { 'configservers':
    ensure  => present,
    timeout => 300,
    servers => $mongos_configServers,
    policy  => all
  }

  if ($mongos_useauth != false) {
    file { "/etc/mongos_${mongos_instance}.key":
      content => template('mongodb/mongos.key.erb'),
      mode    => '0700',
      owner   => $::mongodb::run_as_user,
      require => Class['mongodb::install'],
      notify  => Service["mongos_${mongos_instance}"],
    }
  }

  if ($mongos_service_manage == true) {
    service { "mongos_${mongos_instance}":
      ensure     => $mongos_running,
      enable     => $mongos_enable,
      hasstatus  => true,
      hasrestart => true,
      provider   => $::mongod_service_provider,
      before     => Anchor['mongodb::end'],
      require    => [
        File["/etc/mongos_${mongos_instance}.conf"],
        File["/etc/init.d/mongos_${mongos_instance}"],
        Start_detector['configservers'],
        Service[$::mongodb::old_servicename]
      ]
    }
  }

}
