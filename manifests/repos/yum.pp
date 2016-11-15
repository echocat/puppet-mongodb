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
    enabled  => 1,
    descr    => '10gen MongoDB Repo',
    baseurl  => 'http://downloads-distro.mongodb.org/repo/redhat/os/$basearch',
    gpgcheck => 0;
  }
}
