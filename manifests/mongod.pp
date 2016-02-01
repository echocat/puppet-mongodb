# == definition mongodb::mongod
define mongodb::mongod (
  $mongod_instance                        = $name,
  $mongod_bind_ip                         = '',
  $mongod_port                            = 27017,
  $mongod_replSet                         = '',
  $mongod_enable                          = true,
  $mongod_running                         = true,
  $mongod_configsvr                       = false,
  $mongod_shardsvr                        = false,
  $mongod_logappend                       = true,
  $mongod_rest                            = true,
  $mongod_fork                            = true,
  $mongod_auth                            = false,
  $mongod_useauth                         = false,
  $mongod_monit                           = false,
  $mongod_add_options                     = [],
  $mongod_deactivate_transparent_hugepage = false
) {

# lint:ignore:selector_inside_resource  would not add much to readability

  file {
    "/etc/mongod_${mongod_instance}.conf":
      content => template('mongodb/mongod.conf.erb'),
      mode    => '0755',
      require => Class['mongodb::install'];
    "/etc/init.d/mongod_${mongod_instance}":
      content => template("mongodb/mongod_init/${::osfamily}/init.conf.erb"),
      mode    => '0755',
      require => Class['mongodb::install'];
  }

  if ($::osfamily == 'Debian' and $::operatingsystemmajrelease == 8) {
    file { "mongod_${mongod_instance}_systemd_service":
        path => "/lib/systemd/system/mongod_${mongod_instance}.service",
        content => template("mongodb/mongod_init/${::osfamily}/systemd.conf.erb"),
        mode    => '0644',
        before  => Exec["systemctl_${mongod_instance}_reload"],
        require => [
          Class['mongodb::install'],
          File["/etc/init.d/mongod_${mongod_instance}"]
      ];
    }

    # ensure daemon-reload has been done before service start

    exec { "systemctl_${mongod_instance}_reload":
      command => 'systemctl daemon-reload',
      path    => '/bin',
      before  => Service["mongod_${mongod_instance}"],
    }
  }

# lint:endignore

  if ($mongod_monit != false) {
    # notify { "mongod_monit is : ${mongod_monit}": }
    class { 'mongodb::monit':
      instance_name => $mongod_instance,
      instance_port => $mongod_port,
      require       => Anchor['mongodb::install::end'],
      before        => Anchor['mongodb::end'],
    }
  }

  if ($mongod_useauth != false) {
    file { "/etc/mongod_${mongod_instance}.key":
      content => template('mongodb/mongod.key.erb'),
      mode    => '0700',
      owner   => $mongodb::params::run_as_user,
      require => Class['mongodb::install'],
      notify  => Service["mongod_${mongod_instance}"],
    }
  }

  service { "mongod_${mongod_instance}":
    ensure     => $mongod_running,
    enable     => $mongod_enable,
    hasstatus  => true,
    hasrestart => true,
    provider   => $::mongod_service_provider,
    require    => [
      File[
        "/etc/mongod_${mongod_instance}.conf",
        "/etc/init.d/mongod_${mongod_instance}"],
        Service[$::mongodb::old_servicename]],
    before     => Anchor['mongodb::end']
  }

}
