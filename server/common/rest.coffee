respondIfOk = (req, res) ->
  if res.gintResult?
    res.json 200, res.gintResult
  else
    res.json 500, 'something went wrong'

routeResource = (name, app, authAction, controller) ->
  app.get( '/api/' + name,          authAction, controller.index, respondIfOk)
  app.post('/api/' + name,          authAction, controller.create, respondIfOk)
  app.put( '/api/' + name + '/:id', authAction, controller.update, respondIfOk)
  app.get( '/api/' + name + '/:id', authAction, controller.show, respondIfOk)
  app.del( '/api/' + name + '/:id', authAction, controller.destroy, respondIfOk)

exports.routeResource = routeResource
