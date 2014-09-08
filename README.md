gi-util
-------------

[![Build Status](https://drone.goincremental.com/github.com/GoIncremental/gi-util/status.svg?branch=master)](https://drone.goincremental.com/github.com/GoIncremental/gi-util)

### Release Notes
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
