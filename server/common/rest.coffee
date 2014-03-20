respondIfOk = (req, res) ->
  if res.giResult?
    res.json 200, res.giResult
  else
    res.json 500, {message: 'something went wrong'}

routeResource = (name, app, middleware, controller) ->
  app.get( '/api/' + name
  , middleware, controller.index, @_respondIfOk)
  app.post('/api/' + name
  , middleware, controller.create, @_respondIfOk)
  app.get( '/api/' + name + '/count'
  , middleware, controller.count, @_respondIfOk)
  app.put( '/api/' + name + '/:id'
  , middleware, controller.update, @_respondIfOk)
  app.get( '/api/' + name + '/:id'
  , middleware, controller.show, @_respondIfOk)
  app.del( '/api/' + name + '/:id'
  , middleware, controller.destroy, @_respondIfOk)

exports.routeResource = routeResource
exports._respondIfOk = respondIfOk