## 2014-06-23 - 3.4.0

#### Features:

- specify `package_name` and `package_ensure` to install specific version
- new README examples for version 2.6.x

#### Bugfixes:

- Debian init script uses pidfile correct
- fix package naming on Debian-like systems
- package names are version 2.6.x compatiple now

## 2014-04-22 - 3.3.1

- set ulimit nproc (number of processes) to recommend value 32k (was 1024)
- add parameter to set ulimit nproc
- complete rewrite of README

## 2014-01-10 - 3.3.0

- you can specify which version of mongodb to be installed (package_ensure)
- ensure default init script is replaced on ubuntu on puppet >3.3
- parameter logrotate_package_manage allows you to specify if this module should install logrotate package

## 2013-12-11 - 3.2.1

- fix a bunch of changed variables

## 2013-12-11 - 3.2.0 

- Release adds some more flexability for global parameters
- add @ to puppet variables in erb, to avoid warnings
- added user, group, old_servicename parameters to class mongodb
- update Monit configuration file path for Ubuntu
