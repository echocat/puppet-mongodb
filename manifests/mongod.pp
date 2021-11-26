# == definition mongodb::mongod
define mongodb::mongod (
  $mongod_instance                        = $name,
  $mongod_bind_ip                         = '',
  $mongod_port                            = 27017,
  $mongod_replSet                         = '',
  $mongod_enable                          = true,
  $mongod_restart_on_change               = false,
  $mongod_running                         = true,
  $mongod_configsvr                       = false,
  $mongod_shardsvr                        = false,
  $mongod_logappend                       = true,
  $mongod_rest                            = true,
  $mongod_fork                            = true,
  $mongod_auth                            = false,
  $mongod_useauth                         = false,
  $mongod_engine                          = 'wiredTiger',
  $mongod_monit                           = false,
  $mongod_http                            = false,
  $mongod_operation_profiling_slowms      = '',
  $mongod_operation_profiling_mode        = '',
  $mongod_add_options                     = [],
  $mongod_deactivate_transparent_hugepage = false,
) {

  $db_specific_dir = "${::mongodb::params::dbdir}/mongod_${mongod_instance}"
  $osfamily_lc = downcase($::osfamily)

  if $mongod_restart_on_change {
    $notify = Service["mongod_${mongod_instance}"]
  } else {
    $notify = undef
  }

  if ($mongodb::use_yamlconfig) {
    file {
      "/etc/mongod_${mongod_instance}.conf":
        content => template('mongodb/mongod.conf.yaml.erb'),
        mode    => '0755',
        notify  => $notify,
        require => Class['mongodb::install'];
    }
  } else {
    file {
      "/etc/mongod_${mongod_instance}.conf":
        content => template('mongodb/mongod.conf.erb'),
        mode    => '0755',
        notify  => $notify,
        require => Class['mongodb::install'];
    }
  }

  file {
    $db_specific_dir:
      ensure  => directory,
      owner   => $::mongodb::params::run_as_user,
      group   => $::mongodb::params::run_as_group,
      notify  => $notify,
      require => Class['mongodb::install'],
  }

  if $mongodb::params::systemd_os {
    $service_provider = 'systemd'
    file {
      "/etc/init.d/mongod_${mongod_instance}":
        ensure => absent,
    }
    file { "mongod_${mongod_instance}_thp":
      path    => "/etc/systemd/system/mongod_${mongod_instance}_thp.service",
      content => template('mongodb/systemd/mongod_thp.service.erb'),
      mode    => '0644',
      require => [
        Class['mongodb::install'],
        File["/etc/init.d/mongod_${mongod_instance}"]
      ]
    }
    file { "mongod_${mongod_instance}_service":
      path    => "/etc/systemd/system/mongod_${mongod_instance}.service",
      content => template('mongodb/systemd/mongod.service.erb'),
      mode    => '0644',
      require => [
        Class['mongodb::install'],
        File["/etc/init.d/mongod_${mongod_instance}"]
      ]
    }
  } else {
    # Workaround for Ubuntu 14.04 and Debian 7
    if ( versioncmp($::operatingsystemmajrelease, '14.04') == 0 ) {
      $service_provider = undef # let puppet decide
    } elsif ( versioncmp($::operatingsystemmajrelease, '8') < 0 ) {
      $service_provider = undef # let puppet decide
    } else {
      $service_provider = 'init'
    }

    file { "mongod_${mongod_instance}_service":
        path    => "/etc/init.d/mongod_${mongod_instance}",
        content => template("mongodb/init.d/${osfamily_lc}_mongod.conf.erb"),
        mode    => '0755',
        require => Class['mongodb::install'],
    }
  }

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
    provider   => $service_provider,
    require    => [
      File[
        "/etc/mongod_${mongod_instance}.conf",
        "mongod_${mongod_instance}_service",
        $db_specific_dir],
      Service[$::mongodb::old_servicename]],
    before     => Anchor['mongodb::end']
  }

}
