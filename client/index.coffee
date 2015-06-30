angular.module('gi.util', ['ngResource', 'ngCookies', 'logglyLogger', 'ngTouch'
, 'ngRoute', 'ng.deviceDetector'])
.value('version', '1.8.0')
.config ['giLogProvider', (giLogProvider) ->
  if loggly?
    giLogProvider.setLogglyToken loggly.key
    giLogProvider.setLogglyTags "angular," + loggly.tags
    giLogProvider.setLogglyExtra loggly.extra
]
