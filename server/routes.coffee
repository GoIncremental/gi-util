configure = (app, rest) ->
  rest.routeResource 'timePatterns', app
  , app.middleware.userAction, app.controllers.timePattern

  app.get '/api/geo/country', app.middleware.publicAction
  , app.controllers.geo.country

exports.configure = configure
