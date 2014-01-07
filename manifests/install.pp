# == Class: mongodb::install
#
#
class mongodb::install (
  $package_ensure = 'installed',
  $repo_manage    = true
) {

    anchor { 'mongodb::install::begin': }
    anchor { 'mongodb::install::end': }

    if ($repo_manage == true) {
        include $::mongodb::params::repo_class
        $mongodb_10gen_package_require = [
          Anchor['mongodb::install::begin'],
          Class[$::mongodb::params::repo_class]
        ]
    } else {
        $mongodb_10gen_package_require = [
          Anchor['mongodb::install::begin']
        ]
    }

    package { 'mongodb-stable':
        ensure  => absent,
        name    => $::mongodb::params::old_server_pkg_name,
        require => Anchor['mongodb::install::begin'],
        before  => Anchor['mongodb::install::end']
    }

    package { 'mongodb-10gen':
        ensure  => $package_ensure,
        name    => $::mongodb::params::server_pkg_name,
        require => $mongodb_10gen_package_require,
        before  => Anchor['mongodb::install::end']
    }

}
