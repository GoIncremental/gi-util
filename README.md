gi-util
-------------

[![Build Status](https://drone.goincremental.com/github.com/GoIncremental/gi-util/status.svg?branch=master)](https://drone.goincremental.com/github.com/GoIncremental/gi-util)

### Release Notes
v1.0.10
- Added the ability to select columns to return from find().  Specify select on options
i.e.: options.select = 'name occupation' to return just _id, name and occupation

v1.0.9
- returns record count as part of find() callback

v1.0.8
- fixes issue when using giGeo service behind SSL.  Now proxies back to server

v1.0.7
- client now has giGeo service that allows lookup of country based on ip (1000 req / day)

v1.0.6
- client crud now exports 'cache' to allow you to update the cached items yourself

v1.0.5
- return persisted object from bulk upserts and inserts
- add 'starts with' as a query option

v1.0.4
- reject promises in Services crud when http calls to the resource

v1.0.3
- Corrected issue with last release re save / savePromise

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
