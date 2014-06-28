#mongodb

####Table of Contents

1. [Overview - What is the mongodb module?](#overview)
2. [Module Description - What does this module do?](#module-description)
3. [Setup - The basics of getting started with mongodb](#setup)
    * [Beginning with mongodb - Installation](#beginning-with-mongodb)
    * [Install MongoDB version 2.6 - Installation](#install-mongodb-version-26)
    * [Install exact version - Installation](#install-exact-version)
    * [Configure MongoDB wit run as user](#configure-mongodb-with-run-as-user)
    * [Configure MongoDB cluster](#configuration-mongodb-cluster)
4. [Usage - The class and defined types available for configuration](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: mongodb](#class-mongodb)
        * [Defined Type: mongodb::mongod](#defined-type-mongodbmongod)
        * [Defined Type: mongodb::mongos](#defined-type-mongodbmongos)
5. [Requirements](#requirements)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Contributing to the mongodb module](#contributing)

##Overview

This module installs and makes basic configs for mongodb. That includes mongod and mongos.
Out-of-the-box the defaults are set to install a mongodb version 2.4.x. If you want to use
2.6 see the setup examples below.

##Module Description

[MongoDB](http://www.mongodb.org/), is an open-source document database, and the leading NoSQL database.
This module can be used to set up a simple standalone DB or all components for a full sharding cluster.

##Setup

**What mongodb affects:**

* repos/packages/services/basic configuration files for MongoDB

**What mongodb NOT affects:**

* internal configuration of your MongoDB cluster, like Sharding Members and so on

###Beginning with MongoDB

Starting with a mongodb server with replSet. This will install a 2.4.x version MongoDB:

```puppet
  include mongodb
  mongodb::mongod {
    'my_mongod_instanceX':
      mongod_instance    => 'mongodb1',
      mongod_replSet     => 'mongoShard1',
      mongod_add_options => ['slowms = 50']
  }
```

###Install MongoDB version 2.6

```puppet
  class { 'mongodb':
    package_name  => 'mongodb-org',
    logdir       => '/var/log/mongodb/',
    # only debian like distros
    old_servicename => 'mongod'
  }
  mongodb::mongod {
    'my_mongod_instanceX':
      mongod_instance    => 'mongodb1',
      mongod_replSet     => 'mongoShard1',
      mongod_add_options => ['slowms = 50']
  }
```

###Install exact version

Holy shit, I work in an enterprise environment. I need an specific version.
So on a RHEL like system it would look like this:

```puppet

  # mongodb 2.6.x
  class { 'mongodb':
    package_name   => 'mongodb-org',
    package_ensure => '2.6.2-1',
    logdir         => '/var/log/mongodb/',
    # only debian like distros
    old_servicename => 'mongod'
  }
  
  # mongodb 2.4.x
  class { 'mongodb':
    package_ensure => '2.4.10-mongodb_1',
    logdir         => '/var/log/mongodb/'
  }  
```

###Configure MongoDB with run as user

Now we change the run as user and logdir path.

```puppet
  class { 'mongodb':
    run_as_user  => mongod,
    run_as_group => wheel,
    logdir       => '/nfsshare/mymongologs/'
  }
  mongodb::mongod {
    'my_mongod_instanceX':
      mongod_instance    => 'mongodb1',
      mongod_replSet     => 'mongoShard1',
      mongod_add_options => ['slowms = 20']
}
```

###Configuration mongodb cluster

And here is a more complex example of building a mongo sharding cluster
4 nodes (3 of them config server) with 4 shards in replication.

```puppet
node mongo_sharding_default {

  # Install MongoDB

  include mongodb

  # Install the MongoDB shard server

  mongodb::mongod { 'mongod_Shard1':
    mongod_instance => 'Shard1',
    mongod_port     => 27019,
    mongod_replSet  => 'Shard1',
    mongod_shardsvr => 'true'
  }

  mongodb::mongod { 'mongod_Shard2':
    mongod_instance => 'Shard2',
    mongod_port     => 27020,
    mongod_replSet  => 'Shard2',
    mongod_shardsvr => 'true'
  }

  mongodb::mongod { 'mongod_Shard3':
    mongod_instance => 'Shard3',
    mongod_port     => 27021,
    mongod_replSet  => 'Shard3',
    mongod_shardsvr => 'true'
  }

  mongodb::mongod { 'mongod_Shard4':
    mongod_instance => 'Shard4',
    mongod_port     => 27022,
    mongod_replSet  => 'Shard4',
    mongod_shardsvr => 'true'
  }

  # Install the MongoDB Loadbalancer server

  mongodb::mongos { 'mongos_shardproxy':
    mongos_instance      => 'mongoproxy',
    mongos_port          => 27017,
    mongos_configServers => 'mongo1.my.domain:27018,mongo2.my.domain:27018,mongo3.my.domain:27018'
  }
}

 # This three nodes are shard members and run a mongoS

node 'mongo1.my.domain',
     'mongo2.my.domain',
     'mongo3.my.domain' inherits mongo_sharding_default {

  # Install the MongoDB config server

  include mongodb

  mongodb::mongod { 'mongod_config':
    mongod_instance  => 'shardproxy',
    mongod_port      => 27018,
    mongod_replSet   => '',
    mongod_configsvr => 'true'
  }
}

 # This node is just a shard member

node 'mongo4.my.domain' inherits mongo_sharding_default { }
```

##Usage

###Classes and Defined Types

This module installs mongodb from the repo with class `mongodb`.
The redis service(s) are configured with the defined type `redis::server`.

####Class: `mongodb`

This class installs mongodb packages and makes basic install configurations.
It does not configure any mongo services. This is done by defined type
`mongodb::mongod` and `mongodb::mongos`.

Most global parameters are set in params.pp and should fit the most use cases.
But you can also set them, when including class mongodb.

**Parameters within `mongodb`:**

#####`dbdir`

Default is '/var/lib' (string). This is the root directory where the mongo instances
will create their own subdirectories.

#####`pidfilepath`

Default is `dbdir`.

#####`logdir`

Default on Redhat '/var/log/mongo' and on Debian '/var/log/mongodb'.

#####`logrotatenumber`

Number of days to keep the logfiles.

#####`logrotate_package_manage`

Default is true (boolean). Says if this module should manage logrotate or not.

#####`package_ensure`

Default is 'installed' . Here you can choose the version to be installed.

#####`repo_manage`

Default is true (boolean). Choose if this module should manage the repos needed
to install the mongodb packages.

#####`ulimit_nofiles`

Default is 64000 (integer). Number of allowed filehandles.
See [recommendations](http://docs.mongodb.org/manual/reference/ulimit/#recommended-settings)

#####`ulimit_nproc`

Default is 32000 (integer).
See [recommendations](http://docs.mongodb.org/manual/reference/ulimit/#recommended-settings)

#####`run_as_user`

Default on Redhat is 'mongod' and on Debian 'mongodb' (string). The user the
mongod is run with.

#####`run_as_group`

Default on Redhat is 'mongod' and on Debian 'mongodb' (string). The group the
mongod is run with.

#####`old_servicename`

Default on Redhat is 'mongod' and on Debian 'mongodb' (string).
Name of the origin mongodb package service. his will be deactivated.

####Defined Type: `mongodb::mongod`

Used to configure mongoD instances. You can setup multiple mongodb servers on the
same node. See the setup examples.

**Parameters within `mongodb::mongod`

#####`mongod_instance`

Despription of mongd service (shard1, config, etc)  (required)

#####`mongod_bind_ip`

Default is '' (empty string). So listen in all.

#####`mongod_port`

Listen port (defaul: 27017)

#####`mongod_replSet`

Name of ReplSet (optional)

#####`mongod_enable`

Enable/Disable service at boot (default: true)

#####`mongod_running`

Start/Stop service (default: true)

#####`mongod_configsvr`

Is config server true/false (default: false)

#####`mongod_shardsvr`

Is shard server true/false (default: false)

#####`mongod_logappend`

Enable/Disable log file appending (default: true)

#####`mongod_rest`

Enable/Disable REST api (default: true)

#####`mongod_fork`

Enable/Disable fork of mongod process (default: true)

#####`mongod_auth`

Enable/Disable auth true/false (default: false)

#####`mongod_useauth`

Keyfile contents. Your random string/false (default: false)

#####`mongod_monit`

Use monit monitoring for mongod instances (default: false)

#####`mongod_add_options`

Array. Each field is "key" or "key=value" for parameters for config file

####Defined Type: `mongodb::mongos`

Used to configure mongoS instances. You can setup multiple mongodb proxy
servers on the same node. See the setup examples.

**Parameters within `mongodb::mongos`

#####`mongos_instance`

Despription of mongd service (shard1, config, etc)  (required)

#####`mongos_bind_ip`

Listen ip (defaul: emtpy, so listen in all)

#####`mongos_port`

Listen port (defaul: 27017)

#####`mongos_configServers`

String with comma seperated list of config servers (optional)

#####`mongos_enable`

Enable/Disable service at boot (default: true)

#####`mongos_running`

Start/Stop service (default: true)

#####`mongos_logappend`

Enable/Disable log file appending (default: true)

#####`mongos_fork`

Enable/Disable fork of mongod process (default: true)

#####`mongos_useauth`

Keyfile contents. Your random string/false (default: false)

#####`mongos_add_options`

Array. Each field is "key" or "key=value" for parameters for config file

##Requirements

###Modules needed:

* puppetlabs-stdlib
* puppetlabs-apt ( only for Debian/Ubuntu )

###Software versions needed:

facter > 1.6.2
puppet > 2.6.2

On Redhat distributions you need the EPEL or RPMforge repository, because Graphite needs packages, which are not part of the default repos.

##Limitations

This module is tested on CentOS 6.5 and should also run without problems on

* RHEL/CentOS/Scientific 6+
* Debian 6+
* Ubunutu 10.04 and newer

##Contributing

Echocat modules are open projects. So if you want to make this module even better, you can contribute to this module on [Github](https://github.com/echocat/puppet-mongodb).
