angular.module('gi.util').factory 'giGeo'
, ['$q', '$http', '$cookieStore'
, ( $q, $http, $cookies) ->

  cookieID = "giGeo"

  country: () ->

    deferred = $q.defer()
    country = $cookies.get(cookieID)
    if not country?
      $http.get("http://ipinfo.io/country").success( (c) ->
        $cookies.put(cookieID, c)
        deferred.resolve c
      ).error (data) ->
        deferred.reject data
    else
      deferred.resolve country

    deferred.promise
]
