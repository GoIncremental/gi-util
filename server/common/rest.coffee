respondIfOk = (req, res) ->
  if res.gintResult?
    res.json 200, res.gintResult
  else
    res.json 500, 'something went wrong'

routeResource = (name, app, middleware, controller) ->
  app.get( '/api/' + name,          middleware, controller.index, respondIfOk)
  app.post('/api/' + name,          middleware, controller.create, respondIfOk)
  app.put( '/api/' + name + '/:id', middleware, controller.update, respondIfOk)
  app.get( '/api/' + name + '/:id', middleware, controller.show, respondIfOk)
  app.del( '/api/' + name + '/:id', middleware, controller.destroy, respondIfOk)

exports.routeResource = routeResource
