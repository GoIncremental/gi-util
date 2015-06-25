gi-util
-------------

[![Build Status](https://drone.goincremental.com/github.com/GoIncremental/gi-util/status.svg?branch=master)](https://drone.goincremental.com/github.com/GoIncremental/gi-util)

### Release Notes
v1.7.0
- Added ng-device-detector

v1.6.0
- Added VAT regex to Util service

v1.5.4
- Fixed issue with counters getNext where behaviour had change with mongoose 4.x

v1.5.3
- Add previewNext to counters model - hints at the next number for a given name.

v1.5.2
- Adds Angular Touch and ngRoute to imported modules (no need to import further up the app chain any more)

v1.5.1
- Fixes issue with giMatch where it didn't evaluate the ng-required attribute correctly

v1.5.0
- Fixes issue where items in local storage were double json stringified.
- Adds giUtil angular service, which for now exposes emailRegex property for  
standardising e-mail validation.

v1.4.4
- Merge patch for release 1.0.10 (adds support to filter fields in queries)

v1.4.3
- Merge patch for release 1.0.9 (adds record count to find() callback)

v1.4.2
- Added giMatch directive for form validation to check two fields match
````<input type="text" gi-match="model.property" ng-required="expression to test if this field needs to be validated and non empty" />````

v1.4.1
- Enhanced giLog service to bring it into line with the server side conventions

v1.4.0
- Added giLog service and giAnalytics to allow angular client use of loggly and google analytics.  A fuller implementaion of the API will follow in future releases.

v1.3.2
- Fixes change in behaviour on findByIdAndUpdate introduced in mongoose 4
In Mongoose < 4.X findByIdAndUpdate returned the modified document by default.  This changed in 4.0 so we now pass the options to keep gi-util behaviour the same

v1.3.1
- fixed issue where loggly changed the object before logging, which was causing some upstream issues

v1.3.0
- added support for LOGGLY integration.  Just use gi.log function and pass a string or an object.  To use LOGGLY you must define LOGGLY_API_KEY and LOGGLY_SUBDOMAIN environment variables
- RECOMMENDATION:  ALL gi* applications should define the following environment variables: GI_APP_ENVIRONMENT, GI_APP_VERSION, GI_CUSTOMER and GI_PRODUCT  Loggly logging
will be much nicer as a consequence.
- Feature: formDirectiveFactory added.  This should be used in conjuction with the crud service to provide a standard user experience when editing resources through gi* applications

v1.2.4
- added support for Mongo 3.X, and switched to a better supported mongo-connect

v1.2.3
- compiled js file was not updated in last release

v1.2.2
- Fixed issue where prefix was not honoured on giCrud factory service.

v1.2.1
- Found a better free service that re-enables client side ip geo lookup.  Have removed
the server /api based approach (it had various problems with nginx proxies changing the ip etc)

v1.2.0
- BREAKING CHANGE: Switched from grunt to gulp and moved bower_modules to standard location of bower_components.  Run `gulp` to build gi.js.
gi-util.js now includes all the core dependencies like moment.js, angular.js etc meaning
there is no need to import these again from the customer projects.

- Feature: giLocalStorage service added

v1.1.0
- Feature: dal SQL returns inserted rows after SQL create calls

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
