# MongoDB module

This module manages mongodb services. It provides the functions for mongod and mongos instances.

# Works for

RHEL/CentOS 6+  
Debian 6+  
Ubuntu 10.04 and newer

# Requirements

### Modules needed:

puppetlabs-stdlib ( https://github.com/puppetlabs/puppetlabs-stdlib )  
puppetlabs-apt ( https://github.com/puppetlabs/puppetlabs-apt ) only for Debian/Ubuntu

### Software versions needed:
facter > 1.6.2  
puppet > 2.6.2

# Parameters:

### Global

Most global parameters are set in params.pp and should fit the most use cases.  
But you can also set them, when including class mongodb.  
Parameters:  

   dbdir                    = $mongodb::params::dbdir,  
   pidfilepath              = $mongodb::params::pidfilepath,  
   logdir                   = $mongodb::params::logdir,  
   logrotatenumber          = $mongodb::params::logrotatenumber,  
   logrotate_package_manage = $mongodb::params::logrotate_package_manage,  
   package_ensure           = $mongodb::params::package_ensure,  
   repo_manage              = $mongodb::params::repo_manage,  
   ulimit_nofiles           = $mongodb::params::ulimit_nofiles,  
   ulimit_nproc             = $mongodb::params::ulimit_nofiles,  
   run_as_user              = $mongodb::params::run_as_user,  
   run_as_group             = $mongodb::params::run_as_group,  
   old_servicename          = $mongodb::params::old_servicename  

### Starting mongod

   mongod_instance = despription of mongd service (shard1, config, etc)  (required)  
   mongod_bind_ip = listen ip (defaul; emtpy, so listen in all)  
   mongod_port = listen port (defaul; 27017)  
   mongod_replSet = Name of ReplSet (optional)  
   mongod_enable = Enable/Disable service at boot (default: true)  
   mongod_running = Start/Stop service (default: true)  
   mongod_configsvr = is config server true/false (default: false)  
   mongod_shardsvr = is shard server true/false (default: false)  
   mongod_logappend = Enable/Disable log file appending (default: true)  
   mongod_rest = Enable/Disable REST api (default: true)  
   mongod_fork = Enable/Disable fork of mongod process (default: true)  
   mongod_auth = Enable/Disable auth true/false (default: false)  
   mongod_useauth = Keyfile contents. Your random string/false (default: false)  
   mongod_monit = Use monit monitoring for mongod instances (default: false)  
   mongod_add_options = Array. Each field is "key" or "key=value" for parameters for config file  

### Starting mongos (mongo loadbalancer)

   mongos_instance = despription of mongd service (shard1, config, etc)  (required)  
   mongos_bind_ip = listen ip (defaul; emtpy, so listen in all)  
   mongos_port = listen port (defaul; 27017)  
   mongos_configServers = String with comma seperated list of config servers (optional)  
   mongos_enable = Enable/Disable service at boot (default: true)  
   mongos_running = Start/Stop service (default: true)  
   mongos_logappend = Enable/Disable log file appending (default: true)  
   mongos_fork = Enable/Disable fork of mongod process (default: true)  
   mongos_useauth = Keyfile contents. Your random string/false (default: false)
   mongos_add_options = Array. Each field is "key" or "key=value" for parameters for config file  

# Sample Usage:

## just a mongodb server with replSet
<pre>
	node mongod.my.domain {
		include mongodb
		mongodb::mongod {
			'my_mongod_instanceX':
				mongod_instance    => 'mongodb1',
				mongod_replSet     => 'mongoShard1',
				mongod_add_options => ['fastsync','slowms = 50']
		}
	}
</pre>

## More complex building of mongo sharding cluster ###
4 nodes (3 of them config server) with 4 shards in replecation

<pre>
	node mongo_sharding_default {

    	# Install MongoDB
    	include mongodb

    	# Install the MongoDB shard server
    	mongodb::mongod {'mongod_Shard1': mongod_instance => "Shard1", mongod_port => '27019', mongod_replSet => "Shard1", mongod_shardsvr => 'true' }
    	mongodb::mongod {'mongod_Shard2': mongod_instance => "Shard2", mongod_port => '27020', mongod_replSet => "Shard2", mongod_shardsvr => 'true' }
    	mongodb::mongod {'mongod_Shard3': mongod_instance => "Shard3", mongod_port => '27021', mongod_replSet => "Shard3", mongod_shardsvr => 'true' }
    	mongodb::mongod {'mongod_Shard4': mongod_instance => "Shard4", mongod_port => '27022', mongod_replSet => "Shard4", mongod_shardsvr => 'true' }

    	# Install the MongoDB Loadbalancer server
    	mongodb::mongos {
    		'mongos_profile':
    			mongos_instance      => 'mongoproxy',
    			mongos_port          => 27017,
				  mongos_configServers => 'mongo1.my.domain:27018,mongo2.my.domain:27018,mongo3.my.domain:27018'
    	}
	}

	node 'mongo1.my.domain',
		'mongo2.my.domain',
		'mongo3.my.domain' inherits mongo_sharding_default {

		# Install the MongoDB config server
		include mongodb
		mongodb::mongod {
			'mongod_config':
				mongod_instance  => 'profileConfig',
				mongod_port      => '27018',
				mongod_replSet   => '',
				mongod_configsvr => 'true'
		}
	}

	node 'mongo4.my.domain' inherits mongo_sharding_default { }
</pre>

## Change run as user and logdir path
<pre>
    node mongod.my.domain {
        class { 'mongodb':
          run_as_user  => mongod,
          run_as_group => wheel,
          logdir       => '/nfsshare/mymongologs/'
        }
        mongodb::mongod {
            'my_mongod_instanceX':
                mongod_instance    => 'mongodb1',
                mongod_replSet     => 'mongoShard1',
                mongod_add_options => ['fastsync','slowms = 50']
        }
    }
</pre>


# Author

written by Daniel Werdermann <dwerdermann@web.de>

