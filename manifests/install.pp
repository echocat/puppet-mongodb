# == Class: mongodb::install
#
#
class mongodb::install (
  $repo_manage    = true,
  $package_version = undef
) {

    anchor { 'mongodb::install::begin': }
    anchor { 'mongodb::install::end': }

    if ($repo_manage == true) {
        include $::mongodb::params::repo_class
        $mongodb_10gen_package_require = [
          Anchor['mongodb::install::begin'],
          Class[$::mongodb::params::repo_class]
        ]
        $package_name = $::mongodb::apt::repos::package_name
    } else {
        $mongodb_10gen_package_require = [
          Anchor['mongodb::install::begin']
        ]
        $package_name = $::mongodb::package_name
    }

    if ($package_version == undef ) {
      $package_ensure = $::mongodb::package_ensure
    } else {
      $package_ensure = $::osfamily ? {
        redhat => "${package_version}-mongodb_1",
        debian => $package_version,
      }
    }

    package { 'mongodb-stable':
        ensure  => absent,
        name    => $::mongodb::params::old_server_pkg_name,
        require => Anchor['mongodb::install::begin'],
        before  => Anchor['mongodb::install::end']
    }

    package { 'mongodb-package':
        ensure  => $package_ensure,
        name    => $package_name,
        require => $mongodb_10gen_package_require,
        before  => [Anchor['mongodb::install::end']]
    }

}
