proxyquire = require 'proxyquire'
path = require 'path'
sinon = require 'sinon'
expect = require('chai').expect

module.exports = ->
  stubs = null
  module = null
  app =
    models: 'appModels'
    controllers: 'appControllers'
    middleware: 'appMiddleware'
  stubbedCommon =
    name: 'stubbedCommon'
    rest: 'stubbed-common.rest'
    extend: ->
  stubbedRoutes =
    configure: ->

  stubbedControllers = (arg) ->
    if arg is app
      'controllers-app'
    else
      'controllers-error'

  stubs =
    './common': stubbedCommon
    './routes': stubbedRoutes
    './middleware': 'stubbedMiddleware'
    '../test/server/mocks': 'stubbedMocks'
    './models': sinon.stub().withArgs('dal').returns('models-dal')
    './controllers': stubbedControllers
    './middleware': 'stubbedMiddleware'
  
  dir =  path.normalize __dirname + '../../../server/index'

  describe 'Exports', ->
    beforeEach (done) ->
      module = proxyquire dir, stubs
      done()

    it 'common', (done) ->
      expect(module).to.have.property 'common'
      expect(module.common).to.be.an 'object'
      expect(module.common.name).to.equal 'stubbedCommon'
      done()
      
    it 'mocks', (done) ->
      expect(module).to.have.property 'mocks'
      expect(module.mocks).to.equal 'stubbedMocks'
      done()
    
    it 'configure: function() -> ', (done) ->
      expect(module).to.have.property 'configure'
      expect(module.configure).to.be.a 'function'
      done()

    it 'middleware', (done) ->
      expect(module).to.have.property 'middleware'
      expect(module.middleware).to.equal 'stubbedMiddleware'
      done()

  describe 'configure', (done) ->
    beforeEach (done) ->
      sinon.spy stubbedCommon, 'extend'
      sinon.spy stubbedRoutes, 'configure'

      module = proxyquire dir, stubs

      module.configure app, 'dal'
      done()

    afterEach (done) ->
      stubbedCommon.extend.restore()
      stubbedRoutes.configure.restore()
      done()

    it 'extends app.models with gint-util models', (done) ->
      expect(stubbedCommon.extend.calledWith('appModels', 'models-dal')
      , 'extend not called on models').to.be.true
      done()

    it 'extends app.controllers with gint-util controllers', (done) ->
      expect(stubbedCommon.extend.calledWith(
        'appControllers', 'controllers-app'
      ), 'extend not called on controllers').to.be.true
      done()

    it 'extends app middleware with gint-util middleware', (done) ->
      expect(stubbedCommon.extend.calledWith(
        'appMiddleware', 'stubbedMiddleware'
      ), 'extend not called on middleware').to.be.true
      done()

    it 'configures routes on app using common.rest', (done) ->
      expect(stubbedRoutes.configure.calledWith(
        sinon.match.same(app), 'stubbed-common.rest'
      ), 'routes not configured correctly').to.be.true
      done()

