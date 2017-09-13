# == Class: mongodb
#
class mongodb (
  $systemd_os               = $mongodb::params::systemd_os,
  $dbdir                    = $mongodb::params::dbdir,
  $pidfilepath              = $mongodb::params::pidfilepath,
  $logdir                   = $mongodb::params::logdir,
  $logrotatenumber          = $mongodb::params::logrotatenumber,
  $logrotate_package_manage = $mongodb::params::logrotate_package_manage,
  $package_ensure           = $mongodb::params::package_ensure,
  $package_name             = $mongodb::params::mongodb_pkg_name,
  $repo_manage              = $mongodb::params::repo_manage,
  $ulimit_nofiles           = $mongodb::params::ulimit_nofiles,
  $ulimit_nproc             = $mongodb::params::ulimit_nproc,
  $run_as_user              = $mongodb::params::run_as_user,
  $run_as_group             = $mongodb::params::run_as_group,
  $old_servicename          = $mongodb::params::old_servicename,
  $use_yamlconfig           = $mongodb::params::use_yamlconfig,
  $use_enterprise           = $mongodb::params::use_enterprise,
) inherits mongodb::params {

  anchor { 'mongodb::begin': before => Anchor['mongodb::install::begin'], }
  anchor { 'mongodb::end': }

  case $::osfamily {
    /(?i)(Debian|RedHat)/ : {
      class { 'mongodb::install': repo_manage => $repo_manage }
    }
    default               : {
      fail "Unsupported OS ${::operatingsystem} in 'mongodb' module"
    }
  }

  class { 'mongodb::logrotate':
    require => Anchor['mongodb::install::end'],
    before  => Anchor['mongodb::end'],
  }

  # remove not wanted startup script, because it would kill all mongod
  # instances and not only the default mongod

  file { "/etc/init.d/${::mongodb::old_servicename}":
    ensure  => file,
    content => template("${module_name}/init.d/replacement_mongod.conf.erb"),
    mode    => '0755',
    before  => Anchor['mongodb::end'],
  }

  # stop and disable default mongod
  service { $::mongodb::old_servicename:
    ensure     => stopped,
    enable     => false,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Package['mongodb-package'],
    require    => File["/etc/init.d/${::mongodb::old_servicename}"],
    before     => Anchor['mongodb::end'],
  }

  mongodb::limits::conf {
    'mongod-nofile-soft':
      type  => soft,
      item  => nofile,
      value => $::mongodb::ulimit_nofiles;

    'mongod-nofile-hard':
      type  => hard,
      item  => nofile,
      value => $::mongodb::ulimit_nofiles;

    'mongod-nproc-soft':
      type  => soft,
      item  => nproc,
      value => $::mongodb::ulimit_nproc;

    'mongod-nproc-hard':
      type  => hard,
      item  => nproc,
      value => $::mongodb::ulimit_nproc;
  }

  # ordering resources application

  Mongodb::Mongod<| |> -> Mongodb::Mongos<| |>
}
