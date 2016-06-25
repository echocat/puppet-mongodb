# == Class: mongodb::repo::yum
#
# This class adds the official YUM repo of mongodb.org
#
# === Parameters:
#
# None.
#
class mongodb::repos::yum {

    yumrepo { 'mongodb_yum_repo':
        descr         => '10gen MongoDB Repo',
        baseurl       => 'http://downloads-distro.mongodb.org/repo/redhat/os/$basearch',
        enabled       => 1,
        gpgcheck      => 0;
    }

    yumrepo { 'mongodb_3.2_repo':
        descr         => '3.2 MongoDB Repo',
        baseurl       => 'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/',
        enabled       => 1,
        gpgcheck      => 0,
        gpgkey        => 'https://www.mongodb.org/static/pgp/server-3.2.asc';
    }

    yumrepo { 'mongodb_3.0_repo':
        descr         => '3.0 MongoDB Repo',
        baseurl       => 'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.0/x86_64/',
        enabled       => 1,
        gpgcheck      => 0,
        gpgkey        => 'https://www.mongodb.org/static/pgp/server-3.0.asc';
    }
}
