configure = (app, rest) ->
  rest.routeResource 'timePatterns', app
  , app.middleware.userAction, app.controllers.timePattern

  app.get '/api/geoip'
  , app.middleware.publicAction, app.controllers.geoip.my

exports.configure = configure
