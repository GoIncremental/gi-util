gi-util
-------------

[![Build Status](https://drone.goincremental.com/github.com/GoIncremental/gi-util/status.svg?branch=master)](https://drone.goincremental.com/github.com/GoIncremental/gi-util)

### Release Notes
v1.0.2
- Support for bulk update / insert

v1.0.1
- Support equality queries in sql dal

v1.0.0
- BREAKING CHANGE: giCrud Angular service now only uses promises.  Consumers of this service using callbacks must now switch to using promises, and those already using promises must remove the second argument to calls to Crud.factory() as this is no longer a boolean defining whether or not to use promises

v0.3.18
- Added option to override /api prefix in client angular crud service

v0.3.17
- Added option for mongoose population

v0.3.16
- Pass systemId into posted query

v0.3.15
- Ensure query method expects an array response

v0.3.14
- bin/gi-util.js was not included in previous release

v0.3.13
- Added POST query support via /api/[resource_name]/query route

v0.3.12
- Added #42 query for $exists and isnull

v0.3.11
- Fixed #40 Fixed SQL request queue could hang if timeout occured on connection
