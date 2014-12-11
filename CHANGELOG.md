## 2014-12-11 - 3.4.3 (Bugfix release)

#### Bugfixes:

- puppet-lint to match "approved" requirements
- add first spec tests
- fail on unsupported OS

## 2014-12-02 - 3.4.2 (Bugfix release)

#### Bugfixes:

- inheriting `old_servicename` correctly from main class `mongodb`
- fix different apt source for debian and ubuntu

## 2014-11-08 - 3.4.1 (Bugfix release)

#### Features:

- set some more ulimits default
- cleanup newlines and whitespaces

#### Bugfixes:

- fix absolute variable path from params.pp
- Debian: remove --make-pidfile , because mongod sets pidfile itself

## 2014-06-23 - 3.4.0 (Feature release)

#### Features:

- specify `package_name` and `package_ensure` to install specific version
- new README examples for version 2.6.x

#### Bugfixes:

- Debian init script uses pidfile correct
- fix package naming on Debian-like systems
- package names are version 2.6.x compatiple now

## 2014-04-22 - 3.3.1 (Bugfix release)

- set ulimit nproc (number of processes) to recommend value 32k (was 1024)
- add parameter to set ulimit nproc
- complete rewrite of README

## 2014-01-10 - 3.3.0 (Feature release)

- you can specify which version of mongodb to be installed (package_ensure)
- ensure default init script is replaced on ubuntu on puppet >3.3
- parameter logrotate_package_manage allows you to specify if this module should install logrotate package

## 2013-12-11 - 3.2.1 (Bugfix release)

- fix a bunch of changed variables

## 2013-12-11 - 3.2.0 

- Release adds some more flexability for global parameters
- add @ to puppet variables in erb, to avoid warnings
- added user, group, old_servicename parameters to class mongodb
- update Monit configuration file path for Ubuntu
