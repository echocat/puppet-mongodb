# == Class: mongodb::install
#
#
class mongodb::install {

    anchor { 'mongodb::install::begin': }
    anchor { 'mongodb::install::end': }

    include $::mongodb::params::repo_class

    package { 'mongodb-stable':
        ensure  => absent,
        name    => $::mongodb::params::old_server_pkg_name,
        require => Anchor['mongodb::install::begin'],
        before  => Anchor['mongodb::install::end']
    }

    package { 'mongodb-10gen':
        ensure  => installed,
        name    => $::mongodb::params::server_pkg_name,
        require => [Anchor['mongodb::install::begin'],Class[$::mongodb::params::repo_class]],
        before  => Anchor['mongodb::install::end']
    }

}
