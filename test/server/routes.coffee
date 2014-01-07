path = require 'path'
sinon = require 'sinon'
assert = require 'assert'

dir =  path.normalize __dirname + '../../../server'

module.exports = () ->

  describe 'Routes', ->

    assertRestfulForResource = (resource, security, controllerName) ->
      module = require(dir + '/routes')

      app =
        get: sinon.spy()
        post: sinon.spy()
        del: sinon.spy()
        put: sinon.spy()
        middleware:
          publicAction: sinon.spy()
          userAction: sinon.spy()
          adminAction: sinon.spy()

        controllers:
          timePattern: sinon.spy()

      rest =
        routeResource: sinon.spy()

      securityFilter = app.middleware.publicAction
      if security is 'user'
        securityFilter = app.middleware.userAction
      else if security is 'admin'
        securityFilter = app.middleware.adminAction

      module.configure app, rest

      assert rest.routeResource.calledWith(resource, app)
      , 'routeResource not called for ' + resource
      
      assert rest.routeResource.calledWith(resource, app, securityFilter)
      , 'routeResource ' + resource + ' not called with correct security filter'
      
      assert rest.routeResource.calledWith(
        resource, app, securityFilter, app.controllers[controllerName]
      ), 'routeResource ' + resource + ' not called on correct controller'

    it 'exports a RESTful timePatterns resource', (done) ->
      assertRestfulForResource 'timePatterns', 'user', 'timePattern'
      done()