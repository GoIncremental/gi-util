routeResource = (name, app, authAction, controller) ->
  app.get( '/api/' + name,          authAction, controller.index)
  app.post('/api/' + name,          authAction, controller.create)
  app.put( '/api/' + name + '/:id', authAction, controller.update)
  app.get( '/api/' + name + '/:id', authAction, controller.show)
  app.del( '/api/' + name + '/:id', authAction, controller.destroy)

exports.routeResource = routeResource
