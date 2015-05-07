angular.module 'gi.util', ['ngResource', 'ngCookies', 'logglyLogger']

angular.module('gi.util').config ['giLogProvider', (giLogProvider) ->
  if logglyKey?
    giLogProvider.setLogglyToken logglyKey
]
