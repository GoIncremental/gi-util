angular.module('gi.util').factory 'giGeo'
, ['$q', '$http', '$cookieStore'
, ( $q, $http, $cookies) ->

  cookieID = "giGeo"

  country: () ->
    deferred = $q.defer()
    geoInfo = $cookies.get(cookieID)
    if not geoInfo?
      $http.get("/api/geoip").success( (info) ->
        $cookies.put(cookieID, info)
        deferred.resolve info.country_code
      ).error (data) ->
        deferred.reject data
    else
      deferred.resolve geoInfo.country_code

    deferred.promise
]
