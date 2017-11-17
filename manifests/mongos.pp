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
  $mongos_add_options    = [],
  $mongos_start_detector = true
) {

  $db_specific_dir = "${::mongodb::params::dbdir}/mongos_${mongos_instance}"
  $osfamily_lc = downcase($::osfamily)

  file {
    "/etc/mongos_${mongos_instance}.conf":
      content => template('mongodb/mongos.conf.erb'),
      mode    => '0755',
      # no auto restart of a db because of a config change
      # notify => Class['mongodb::service'],
      require => Class['mongodb::install'];
    $db_specific_dir:
      ensure => directory,
      owner  => $::mongodb::params::run_as_user,
      group  => $::mongodb::params::run_as_group;
  }

  if $mongodb::params::systemd_os {
    $service_provider = 'systemd'
    file {
      "/etc/init.d/mongos_${mongos_instance}":
        ensure => absent,
    }
    file { "mongos_${mongos_instance}_service":
      path    => "/lib/systemd/system/mongos_${mongos_instance}.service",
      content => template('mongodb/systemd/mongos.service.erb'),
      mode    => '0644',
      require => [
        Class['mongodb::install'],
        File["/etc/init.d/mongos_${mongos_instance}"]
      ]
    }
  } else {
    # Workaround for Ubuntu 14.04
    if ( versioncmp($::operatingsystemmajrelease, '14.04') == 0 ) {
      $service_provider = undef # let puppet decide
    } else {
      $service_provider = 'init'
    }

    file { "mongos_${mongos_instance}_service":
        path    => "/etc/init.d/mongos_${mongos_instance}",
        content => template("mongodb/init.d/${osfamily_lc}_mongos.conf.erb"),
        mode    => '0755',
        require => Class['mongodb::install'],
    }
  }

  # wait for servers starting
  if $mongos_start_detector {
    start_detector { 'configservers':
      ensure  => present,
      timeout => 120,
      servers => $mongos_configServers,
      policy  => one
    }
  }

  if ($mongos_useauth != false) {
    file { "/etc/mongos_${mongos_instance}.key":
      content => template('mongodb/mongos.key.erb'),
      mode    => '0700',
      owner   => $::mongodb::params::run_as_user,
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
      provider   => $service_provider,
      require    => [
        File[
          "/etc/mongos_${mongos_instance}.conf",
          "mongos_${mongos_instance}_service",
          $db_specific_dir],
        Service[$::mongodb::old_servicename],
        Start_detector['configservers']],
      before     => Anchor['mongodb::end']
    }
  }

}
