angular.module('gi.util').factory 'giGeo'
, ['$q', '$http', '$cookieStore'
, ( $q, $http, $cookies) ->

  cookieID = "giGeo"

  country: () ->

    deferred = $q.defer()
    geoInfo = $cookies.get(cookieID)
    if not geoInfo?
      $http.get("/api/geo/country").success( (info) ->
        $cookies.put(cookieID, info)
        deferred.resolve info.countryCode
      ).error (data) ->
        deferred.reject data
    else
      deferred.resolve geoInfo.countryCode

    deferred.promise
]
